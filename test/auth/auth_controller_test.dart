import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tyt/auth/auth_api.dart';
import 'package:tyt/auth/auth_controller.dart';
import 'package:tyt/auth/kakao_login.dart';
import 'package:tyt/auth/token_storage.dart';

import '../fakes.dart';

const saved = Tokens(accessToken: 'a1', refreshToken: 'r1');

void main() {
  ProviderContainer container({
    required MemoryTokenStorage storage,
    FakeAuthApi? api,
    String? kakaoAccessToken,
  }) => ProviderContainer.test(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authApiProvider.overrideWithValue(api ?? FakeAuthApi()),
      kakaoLoginProvider.overrideWithValue(FakeKakaoLogin(kakaoAccessToken)),
    ],
  );

  group('앱 시작', () {
    test('저장된 토큰이 없으면 서버를 부르지 않고 로그아웃 상태다', () async {
      final api = FakeAuthApi();
      final c = container(storage: MemoryTokenStorage(), api: api);

      expect(await c.read(authControllerProvider.future), AuthStatus.signedOut);
      expect(api.getMeCalls, 0);
    });

    test('저장된 토큰으로 /users/me가 성공하면 로그인 상태다', () async {
      final c = container(storage: MemoryTokenStorage(saved));

      expect(await c.read(authControllerProvider.future), AuthStatus.signedIn);
    });

    test('USER_NOT_FOUND면 토큰을 지우고 로그아웃 상태다', () async {
      final storage = MemoryTokenStorage(saved);
      final c = container(
        storage: storage,
        api: FakeAuthApi(getMeError: apiError(404, 'USER_NOT_FOUND')),
      );

      expect(await c.read(authControllerProvider.future), AuthStatus.signedOut);
      expect(storage.tokens, isNull);
    });

    test('재발급까지 실패한 401이면 토큰을 지우고 로그아웃 상태다', () async {
      final storage = MemoryTokenStorage(saved);
      final c = container(
        storage: storage,
        api: FakeAuthApi(getMeError: apiError(401, 'UNAUTHENTICATED')),
      );

      expect(await c.read(authControllerProvider.future), AuthStatus.signedOut);
      expect(storage.tokens, isNull);
    });
  });

  group('로그인', () {
    test('카카오 토큰으로 서버에 로그인하고 받은 토큰을 저장한다', () async {
      final storage = MemoryTokenStorage();
      final api = FakeAuthApi(loginTokens: saved);
      final c = container(
        storage: storage,
        api: api,
        kakaoAccessToken: 'kakao',
      );
      await c.read(authControllerProvider.future);

      await c.read(authControllerProvider.notifier).login();

      expect(api.loginCalls, ['kakao']);
      expect(storage.tokens!.accessToken, 'a1');
      expect(c.read(authControllerProvider).value, AuthStatus.signedIn);
    });

    test('카카오 로그인을 취소하면 서버를 부르지 않는다', () async {
      final api = FakeAuthApi(loginTokens: saved);
      final c = container(storage: MemoryTokenStorage(), api: api);
      await c.read(authControllerProvider.future);

      await c.read(authControllerProvider.notifier).login();

      expect(api.loginCalls, isEmpty);
      expect(c.read(authControllerProvider).value, AuthStatus.signedOut);
    });

    test('로그인한 뒤 세션이 만료되면 로그아웃 상태가 된다', () async {
      final c = container(storage: MemoryTokenStorage(saved));
      await c.read(authControllerProvider.future);

      c.read(authControllerProvider.notifier).sessionExpired();

      expect(c.read(authControllerProvider).value, AuthStatus.signedOut);
    });
  });
}
