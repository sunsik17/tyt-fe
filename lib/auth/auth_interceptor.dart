import 'package:dio/dio.dart';

import '../api/api_client.dart';
import 'token_storage.dart';

/// access 토큰을 붙이고, 401 UNAUTHENTICATED면 재발급한 뒤 한 번 다시 보낸다
/// (api-guide.md "401을 받았을 때").
///
/// QueuedInterceptor라 onError를 한 번에 하나씩 처리한다. 앞선 요청이 이미 재발급했으면
/// 뒤 요청은 재발급 없이 새 토큰으로 재시도만 한다. 같은 refresh 토큰을 두 번 보내면
/// 두 번째가 INVALID_REFRESH_TOKEN을 받아 멀쩡한 사용자가 로그아웃되기 때문이다.
///
/// 재발급과 재시도는 이 인터셉터가 없는 plainDio로 보낸다. 같은 Dio로 보내면
/// 재시도의 에러가 지금 처리 중인 onError 뒤에 줄을 서서 서로를 기다린다.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.storage,
    required this.plainDio,
    required this.onSessionExpired,
  });

  final TokenStorage storage;
  final Dio plainDio;

  /// 재발급까지 실패해 토큰을 지운 뒤 부른다. 로그인 화면으로 보내는 건 받는 쪽이 한다.
  final void Function() onSessionExpired;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final tokens = await storage.read();
    if (tokens != null) {
      options.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final current = await storage.read();
    if (err.response?.statusCode != 401 ||
        errorCode(err) != 'UNAUTHENTICATED' ||
        current == null) {
      handler.next(err);
      return;
    }

    var tokens = current;
    final sentWith = err.requestOptions.headers['Authorization'];
    if (sentWith == 'Bearer ${current.accessToken}') {
      try {
        final res = await plainDio.post(
          '/api/v1/auth/tokens',
          data: {'refreshToken': current.refreshToken},
        );
        tokens = Tokens.fromJson(res.data['data'] as Map<String, dynamic>);
        await storage.save(tokens);
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) await _expire();
        handler.next(err);
        return;
      }
    }

    final retry = err.requestOptions
      ..headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    try {
      handler.resolve(await plainDio.fetch(retry));
    } on DioException catch (e) {
      // 재발급한 토큰으로도 401이면 로그인 화면으로 보낸다
      if (e.response?.statusCode == 401) await _expire();
      handler.next(e);
    }
  }

  Future<void> _expire() async {
    await storage.clear();
    onSessionExpired();
  }
}
