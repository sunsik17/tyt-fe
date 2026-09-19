/// env/dev.json을 `flutter run --dart-define-from-file=env/dev.json`으로 넘긴다.
/// 저장소에는 값이 빈 env/example.json만 있다.
abstract final class Env {
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const kakaoNativeAppKey = String.fromEnvironment(
    'KAKAO_NATIVE_APP_KEY',
  );
}
