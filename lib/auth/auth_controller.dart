import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import 'auth_api.dart';
import 'kakao_login.dart';
import 'token_storage.dart';

enum AuthStatus { signedOut, signedIn }

class AuthController extends AsyncNotifier<AuthStatus> {
  /// 앱 시작. 저장된 토큰이 없으면 호출 없이 로그인 화면, 있으면 /users/me로 확인한다
  /// (api-guide.md 화면별로 쓰는 API).
  @override
  Future<AuthStatus> build() async {
    final storage = ref.read(tokenStorageProvider);
    if (await storage.read() == null) return AuthStatus.signedOut;
    try {
      await ref.read(authApiProvider).getMe();
      return AuthStatus.signedIn;
    } on DioException catch (e) {
      // 401은 인터셉터가 재발급까지 시도하고도 실패한 경우다
      if (e.response?.statusCode == 401 || errorCode(e) == 'USER_NOT_FOUND') {
        await storage.clear();
        return AuthStatus.signedOut;
      }
      rethrow;
    }
  }

  /// 사용자가 카카오 로그인을 취소하면 아무것도 하지 않는다. 실패는 호출한 화면으로 던진다.
  Future<void> login() async {
    final kakaoAccessToken = await ref.read(kakaoLoginProvider).login();
    if (kakaoAccessToken == null) return;
    final tokens = await ref
        .read(authApiProvider)
        .loginWithKakao(kakaoAccessToken);
    await ref.read(tokenStorageProvider).save(tokens);
    state = const AsyncData(AuthStatus.signedIn);
  }

  /// 재발급까지 실패해 인터셉터가 토큰을 지웠을 때 부른다.
  /// 앱 시작 확인 중이면 build가 직접 로그아웃 상태를 돌려주므로 건드리지 않는다.
  void sessionExpired() {
    if (state.value == AuthStatus.signedIn) {
      state = const AsyncData(AuthStatus.signedOut);
    }
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthStatus>(AuthController.new);
