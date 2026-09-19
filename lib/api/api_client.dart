import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_interceptor.dart';
import '../auth/token_storage.dart';
import '../config/env.dart';

/// 토큰 없이 부르는 로그인·재발급과, 인터셉터의 재시도에 쓴다.
final plainDioProvider = Provider<Dio>(
  (ref) => Dio(BaseOptions(baseUrl: Env.apiBaseUrl)),
);

/// 인증이 필요한 API에 쓴다. access 토큰을 붙이고 401이면 재발급한다.
final apiDioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(baseUrl: Env.apiBaseUrl));
  dio.interceptors.add(
    AuthInterceptor(
      storage: ref.watch(tokenStorageProvider),
      plainDio: ref.watch(plainDioProvider),
      onSessionExpired: () =>
          ref.read(authControllerProvider.notifier).sessionExpired(),
    ),
  );
  return dio;
});

/// 응답 봉투의 `code`. 화면 분기는 이 값으로 한다 (api-guide.md 응답 봉투).
String? errorCode(DioException e) {
  final data = e.response?.data;
  return data is Map ? data['code'] as String? : null;
}
