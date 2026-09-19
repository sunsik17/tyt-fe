import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tyt/app.dart';
import 'package:tyt/auth/auth_api.dart';
import 'package:tyt/auth/kakao_login.dart';
import 'package:tyt/auth/token_storage.dart';

import 'fakes.dart';

void main() {
  Widget app(MemoryTokenStorage storage) => ProviderScope(
    overrides: [
      tokenStorageProvider.overrideWithValue(storage),
      authApiProvider.overrideWithValue(FakeAuthApi()),
      kakaoLoginProvider.overrideWithValue(FakeKakaoLogin(null)),
    ],
    child: const TytApp(),
  );

  testWidgets('저장된 토큰이 없으면 로그인 화면을 띄운다', (tester) async {
    await tester.pumpWidget(app(MemoryTokenStorage()));
    await tester.pumpAndSettle();

    expect(find.text('카카오 로그인'), findsOneWidget);
  });

  testWidgets('저장된 토큰이 유효하면 로그인 화면을 건너뛴다', (tester) async {
    const tokens = Tokens(accessToken: 'a1', refreshToken: 'r1');
    await tester.pumpWidget(app(MemoryTokenStorage(tokens)));
    await tester.pumpAndSettle();

    expect(find.text('카카오 로그인'), findsNothing);
    expect(find.text('로그인했어요'), findsOneWidget);
  });
}
