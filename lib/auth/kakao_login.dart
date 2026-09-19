import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

abstract interface class KakaoLogin {
  /// 카카오 액세스 토큰. 사용자가 취소하면 null.
  Future<String?> login();
}

/// 카카오톡이 있으면 카카오톡으로, 없거나 카카오톡 로그인에 실패하면 카카오계정으로 로그인한다.
/// 카카오 공식 예제의 로그인 조합을 따른다.
class SdkKakaoLogin implements KakaoLogin {
  @override
  Future<String?> login() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          return (await UserApi.instance.loginWithKakaoTalk()).accessToken;
        } catch (e) {
          // 사용자가 취소했으면 카카오계정 로그인으로 넘어가지 않는다
          if (_isCancel(e)) return null;
        }
      }
      return (await UserApi.instance.loginWithKakaoAccount()).accessToken;
    } catch (e) {
      if (_isCancel(e)) return null;
      rethrow;
    }
  }

  bool _isCancel(Object e) =>
      (e is PlatformException && e.code == 'CANCELED') ||
      (e is KakaoClientException && e.reason == ClientErrorCause.cancelled) ||
      (e is KakaoAuthException && e.error == AuthErrorCause.accessDenied);
}

final kakaoLoginProvider = Provider<KakaoLogin>((ref) => SdkKakaoLogin());
