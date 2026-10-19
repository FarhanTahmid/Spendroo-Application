import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:spendroo/core/api/api_client.dart';

/// ApiClient over real sockets: its own connection opener, not a test double.
void main() {
  test('a request goes through and its connection is reused', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final peers = <int>{};
    server.listen((request) {
      peers.add(request.connectionInfo!.remotePort);
      request.response
        ..headers.contentType = ContentType.json
        ..write('{"path": "${request.uri.path}", "token": "${request.headers.value('X-Session-Token')}"}')
        ..close();
    });
    addTearDown(() => server.close(force: true));
    final api = ApiClient(baseUrl: 'http://127.0.0.1:${server.port}', tokenStore: MemoryTokenStore()..token = 'abc');

    final first = await api.get('/api/v1/one/');
    final second = await api.post('/api/v1/two/', {'a': 1});

    expect(first.json, {'path': '/api/v1/one/', 'token': 'abc'});
    expect(second.json['path'], '/api/v1/two/');
    expect(peers, hasLength(1));
  });

  test('a server that refuses the connection reads as offline at once', () async {
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final port = closed.port;
    await closed.close();
    final api = ApiClient(baseUrl: 'http://127.0.0.1:$port', tokenStore: MemoryTokenStore());

    final clock = Stopwatch()..start();
    await expectLater(api.get('/api/v1/'), throwsA(isA<OfflineException>()));
    // No waiting out the next try's delay when the first fails outright
    expect(clock.elapsed, lessThan(const Duration(seconds: 2)));
  });
}
