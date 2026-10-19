import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
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
      : _http = httpClient ?? http.Client();

  final String baseUrl;
  final TokenStore tokenStore;
  final http.Client _http;

  static const _timeout = Duration(seconds: 20);

  /// A file the server makes on request is laid out while the phone waits
  static const _downloadTimeout = Duration(seconds: 90);

  /// A bill of tens of megabytes on a slow connection
  static const _uploadTimeout = Duration(minutes: 5);

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
    final request = _ProgressRequest('POST', Uri.parse('$baseUrl$path'), onProgress)
      ..fields.addAll(fields)
      ..files.add(http.MultipartFile.fromBytes(
        field,
        bytes,
        filename: filename,
        contentType: contentType == null ? null : MediaType.parse(contentType),
      ));
    return _decode(await _fetch(request, timeout: _uploadTimeout));
  }

  /// A file behind a link the server handed out: a path on this server, or a
  /// full address on a file store. The session goes only to this server.
  Future<http.Response> fetchFile(String location) {
    final absolute = location.startsWith('http://') || location.startsWith('https://');
    return _fetch(
      http.Request('GET', Uri.parse(absolute ? location : '$baseUrl$location')),
      timeout: _downloadTimeout,
      withSession: !absolute,
    );
  }

  /// The raw body, such as a picture. Null when the server has nothing there.
  Future<Uint8List?> getBytes(String path) async {
    final response = await _fetch(http.Request('GET', Uri.parse('$baseUrl$path')));
    return response.statusCode == 200 ? response.bodyBytes : null;
  }

  /// A file the server makes on request, such as a report. The answer as it
  /// came: the file on 200, else the server's reason as JSON.
  Future<http.Response> download(String path, {Map<String, String>? query}) => _fetch(
        http.Request('GET', Uri.parse('$baseUrl$path').replace(queryParameters: query)),
        timeout: _downloadTimeout,
      );

  Future<ApiResponse> _send(String method, String path, {Object? body, Map<String, String>? query}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final request = http.Request(method, uri);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    return _decode(await _fetch(request));
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

  Future<http.Response> _fetch(http.BaseRequest request, {Duration timeout = _timeout, bool withSession = true}) async {
    request.headers['Accept'] = 'application/json';
    final token = withSession ? await tokenStore.read() : null;
    if (token != null) request.headers['X-Session-Token'] = token;
    try {
      return await http.Response.fromStream(await _http.send(request).timeout(timeout));
    } on SocketException {
      throw const OfflineException();
    } on TimeoutException {
      throw const OfflineException();
    } on http.ClientException {
      throw const OfflineException();
    }
  }
}

/// A multipart request that says how much of its body has gone out.
class _ProgressRequest extends http.MultipartRequest {
  _ProgressRequest(super.method, super.url, this.onProgress);

  final void Function(double sent)? onProgress;

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
