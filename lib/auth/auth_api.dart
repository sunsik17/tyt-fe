import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'token_storage.dart';

class AuthApi {
  AuthApi(this._plainDio, this._apiDio);

  final Dio _plainDio;
  final Dio _apiDio;

  /// 처음 보는 카카오 계정이면 서버가 가입까지 한다.
  Future<Tokens> loginWithKakao(String kakaoAccessToken) async {
    final res = await _plainDio.post(
      '/api/v1/auth/kakao/tokens',
      data: {'accessToken': kakaoAccessToken},
    );
    return Tokens.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  /// 저장된 토큰을 아직 쓸 수 있는지 확인한다. 응답 본문은 아직 쓰지 않는다.
  Future<void> getMe() async {
    await _apiDio.get('/api/v1/users/me');
  }
}

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(plainDioProvider), ref.watch(apiDioProvider)),
);
