import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tyt/auth/auth_interceptor.dart';
import 'package:tyt/auth/token_storage.dart';

import '../fakes.dart';

/// 경로별로 응답을 정하는 가짜 서버.
class FakeServer implements HttpClientAdapter {
  FakeServer(this.respond);

  final ResponseBody Function(RequestOptions options) respond;
  final requests = <RequestOptions>[];

  int count(String path) => requests.where((r) => r.path == path).length;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, String code, [Object? data]) =>
    ResponseBody.fromString(
      jsonEncode({'code': code, 'message': '', 'data': data}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

const me = '/api/v1/users/me';
const reissue = '/api/v1/auth/tokens';
const oldTokens = Tokens(accessToken: 'a1', refreshToken: 'r1');
const newTokens = {'accessToken': 'a2', 'refreshToken': 'r2'};

void main() {
  late MemoryTokenStorage storage;
  late int expired;

  Dio buildApiDio(FakeServer server) {
    final plain = Dio()..httpClientAdapter = server;
    return Dio()
      ..httpClientAdapter = server
      ..interceptors.add(
        AuthInterceptor(
          storage: storage,
          plainDio: plain,
          onSessionExpired: () => expired++,
        ),
      );
  }

  /// a2 토큰으로 온 요청만 통과시키는 서버. 재발급하면 a2를 준다.
  ResponseBody acceptsOnlyNewToken(RequestOptions o) {
    if (o.path == reissue) return json(200, 'TOKEN_REISSUED', newTokens);
    return o.headers['Authorization'] == 'Bearer a2'
        ? json(200, 'USER_FOUND', {'id': 1})
        : json(401, 'UNAUTHENTICATED');
  }

  setUp(() {
    storage = MemoryTokenStorage(oldTokens);
    expired = 0;
  });

  test('access가 만료되면 재발급한 토큰을 저장하고 원래 요청을 다시 보낸다', () async {
    final server = FakeServer(acceptsOnlyNewToken);

    final res = await buildApiDio(server).get(me);

    expect(res.statusCode, 200);
    expect(storage.tokens!.accessToken, 'a2');
    expect(storage.tokens!.refreshToken, 'r2');
    expect(server.count(reissue), 1);
  });

  test('동시에 두 요청이 401을 받아도 재발급은 한 번만 보낸다', () async {
    final server = FakeServer(acceptsOnlyNewToken);
    final dio = buildApiDio(server);

    final results = await Future.wait([dio.get(me), dio.get(me)]);

    expect(results.map((r) => r.statusCode), [200, 200]);
    expect(server.count(reissue), 1);
  });

  test('재발급이 INVALID_REFRESH_TOKEN이면 토큰을 지우고 세션 만료를 알린다', () async {
    final server = FakeServer((o) {
      if (o.path == reissue) return json(401, 'INVALID_REFRESH_TOKEN');
      return json(401, 'UNAUTHENTICATED');
    });

    await expectLater(
      buildApiDio(server).get(me),
      throwsA(isA<DioException>()),
    );

    expect(storage.tokens, isNull);
    expect(expired, 1);
  });

  test('재발급한 토큰으로도 401이면 토큰을 지우고 세션 만료를 알린다', () async {
    final server = FakeServer((o) {
      if (o.path == reissue) return json(200, 'TOKEN_REISSUED', newTokens);
      return json(401, 'UNAUTHENTICATED');
    });

    await expectLater(
      buildApiDio(server).get(me),
      throwsA(isA<DioException>()),
    );

    expect(storage.tokens, isNull);
    expect(expired, 1);
    expect(server.count(reissue), 1);
  });

  test('401이 아닌 에러는 재발급하지 않고 그대로 넘긴다', () async {
    final server = FakeServer((o) => json(404, 'USER_NOT_FOUND'));

    await expectLater(
      buildApiDio(server).get(me),
      throwsA(isA<DioException>()),
    );

    expect(server.count(reissue), 0);
    expect(storage.tokens, isNotNull);
  });
}
