import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';

/// The request never reached the server (no network, timeout, server down).
class OfflineException implements Exception {
  const OfflineException();
}

class ApiResponse {
  ApiResponse(this.statusCode, this.body);

  final int statusCode;

  /// Decoded JSON: a Map, a List or null.
  final dynamic body;

  bool get ok => statusCode >= 200 && statusCode < 300;
  Map<String, dynamic> get json => (body as Map).cast<String, dynamic>();
}

/// Where the session token lives between launches.
abstract class TokenStore {
  Future<String?> read();
  Future<void> write(String? token);
}

class SecureTokenStore implements TokenStore {
  static const _storage = FlutterSecureStorage();
  static const _key = 'session_token';

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> write(String? token) =>
      token == null ? _storage.delete(key: _key) : _storage.write(key: _key, value: token);
}

class MemoryTokenStore implements TokenStore {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> write(String? token) async => this.token = token;
}

/// Thin JSON-over-HTTP client. Sends the allauth session token on every request.
class ApiClient {
  ApiClient({required this.baseUrl, required this.tokenStore, http.Client? httpClient})
      : _http = httpClient ?? IOClient(_socketClient());

  final String baseUrl;
  final TokenStore tokenStore;
  final http.Client _http;

  static const _timeout = Duration(seconds: 20);

  /// A file the server makes on request is laid out while the phone waits
  static const _downloadTimeout = Duration(seconds: 90);

  /// A bill of tens of megabytes on a slow connection
  static const _uploadTimeout = Duration(minutes: 5);

  /// Longest wait for a connection to open, all attempts together
  static const _connectTimeout = Duration(seconds: 15);

  /// When a connection is still opening after this, another try starts beside it
  static const _connectRetryAfter = Duration(milliseconds: 2500);
  static const _connectAttempts = 4;

  static HttpClient _socketClient() => HttpClient()
    ..connectionTimeout = _connectTimeout
    ..connectionFactory = _connect;

  /// Opens a connection, starting a fresh try beside one that hangs.
  ///
  /// When the first packet of a connection is lost (a flaky mobile network, a
  /// busy router, the Android emulator's network relay) the phone resends it
  /// only after 1, 3, 7, 15 and 31 seconds, so one lost packet can outlast
  /// [_timeout] and show the app as offline. A new try goes out on its own
  /// path; the first to connect is used and the rest are dropped. A try that
  /// fails outright (no network, server down) fails the request at once.
  static Future<ConnectionTask<Socket>> _connect(Uri url, String? proxyHost, int? proxyPort) async {
    final host = proxyHost ?? url.host;
    final port = proxyPort ?? url.port;
    final secure = proxyHost == null && url.isScheme('https');
    final opened = Completer<Socket>();
    final tries = <ConnectionTask<Socket>>[];
    var open = 0;
    Timer? nextTry;

    void stop() {
      nextTry?.cancel();
      for (final task in tries) {
        task.cancel();
      }
    }

    Future<void> attempt(int number) async {
      open++;
      if (number < _connectAttempts) nextTry = Timer(_connectRetryAfter, () => attempt(number + 1));
      try {
        final task = secure ? await SecureSocket.startConnect(host, port) : await Socket.startConnect(host, port);
        if (opened.isCompleted) return task.cancel();
        tries.add(task);
        final socket = await task.socket;
        if (opened.isCompleted) return socket.destroy();
        opened.complete(socket);
        stop();
      } catch (error, stack) {
        if (--open == 0 && !opened.isCompleted) {
          stop();
          opened.completeError(error, stack);
        }
      }
    }

    unawaited(attempt(1));
    return ConnectionTask.fromSocket(opened.future, () {
      stop();
      if (!opened.isCompleted) opened.completeError(const SocketException('Connection attempt cancelled'));
    });
  }

  Future<ApiResponse> get(String path, {Map<String, String>? query}) => _send('GET', path, query: query);
  Future<ApiResponse> post(String path, [Object? body]) => _send('POST', path, body: body);
  Future<ApiResponse> patch(String path, [Object? body]) => _send('PATCH', path, body: body);
  Future<ApiResponse> put(String path, [Object? body]) => _send('PUT', path, body: body);
  Future<ApiResponse> delete(String path) => _send('DELETE', path);

  /// Sends one file as multipart form data, the way Django expects an upload.
  /// [fields] go along as form fields; [onProgress] hears the share sent so far (0 to 1).
  Future<ApiResponse> upload(
    String path, {
    required String field,
    required List<int> bytes,
    required String filename,
    String? contentType,
    Map<String, String> fields = const {},
    void Function(double sent)? onProgress,
  }) async {
    final response = await _fetch(
      (abort) => _ProgressRequest('POST', Uri.parse('$baseUrl$path'), onProgress, abort)
        ..fields.addAll(fields)
        ..files.add(http.MultipartFile.fromBytes(
          field,
          bytes,
          filename: filename,
          contentType: contentType == null ? null : MediaType.parse(contentType),
        )),
      timeout: _uploadTimeout,
    );
    return _decode(response);
  }

  /// A file behind a link the server handed out: a path on this server, or a
  /// full address on a file store. The session goes only to this server.
  Future<http.Response> fetchFile(String location) {
    final absolute = location.startsWith('http://') || location.startsWith('https://');
    return _fetch(
      (abort) => http.AbortableRequest('GET', Uri.parse(absolute ? location : '$baseUrl$location'), abortTrigger: abort),
      timeout: _downloadTimeout,
      withSession: !absolute,
    );
  }

  /// The raw body, such as a picture. Null when the server has nothing there.
  Future<Uint8List?> getBytes(String path) async {
    final response = await _fetch((abort) => http.AbortableRequest('GET', Uri.parse('$baseUrl$path'), abortTrigger: abort));
    return response.statusCode == 200 ? response.bodyBytes : null;
  }

  /// A file the server makes on request, such as a report. The answer as it
  /// came: the file on 200, else the server's reason as JSON.
  Future<http.Response> download(String path, {Map<String, String>? query}) => _fetch(
        (abort) => http.AbortableRequest('GET', Uri.parse('$baseUrl$path').replace(queryParameters: query), abortTrigger: abort),
        timeout: _downloadTimeout,
      );

  Future<ApiResponse> _send(String method, String path, {Object? body, Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final encoded = body == null ? null : jsonEncode(body);
    return _decode(await _fetch((abort) {
      final request = http.AbortableRequest(method, uri, abortTrigger: abort);
      if (encoded != null) {
        request.headers['Content-Type'] = 'application/json';
        request.body = encoded;
      }
      return request;
    }));
  }

  ApiResponse _decode(http.Response response) {
    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        decoded = null; // an HTML error page from a proxy, for example
      }
    }
    return ApiResponse(response.statusCode, decoded);
  }

  /// [timeout] covers the whole exchange, body included. When it runs out the
  /// request is aborted, which also frees its connection: a request merely
  /// given up on keeps its connection busy until the server answers.
  Future<http.Response> _fetch(
    http.BaseRequest Function(Future<void> abort) build, {
    Duration timeout = _timeout,
    bool withSession = true,
  }) async {
    final abort = Completer<void>();
    final request = build(abort.future)..headers['Accept'] = 'application/json';
    final token = withSession ? await tokenStore.read() : null;
    if (token != null) request.headers['X-Session-Token'] = token;
    final deadline = Timer(timeout, abort.complete);
    try {
      // The outer timeout catches a client that cannot abort, such as a test double
      return await http.Response.fromStream(await _http.send(request)).timeout(timeout + const Duration(seconds: 1));
    } on SocketException {
      throw const OfflineException();
    } on TimeoutException {
      throw const OfflineException();
    } on http.ClientException {
      throw const OfflineException();
    } finally {
      deadline.cancel();
    }
  }
}

/// A multipart request that says how much of its body has gone out.
class _ProgressRequest extends http.MultipartRequest with http.Abortable {
  _ProgressRequest(super.method, super.url, this.onProgress, this.abortTrigger);

  final void Function(double sent)? onProgress;

  @override
  final Future<void>? abortTrigger;

  @override
  http.ByteStream finalize() {
    final body = super.finalize();
    final listener = onProgress;
    if (listener == null) return body;
    final total = contentLength;
    var sent = 0;
    return http.ByteStream(body.map((chunk) {
      sent += chunk.length;
      if (total > 0) listener(sent / total);
      return chunk;
    }));
  }
}
