import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/auth_controller.dart';
import 'auth/login_screen.dart';
import 'theme/tyt_theme.dart';

class TytApp extends ConsumerWidget {
  const TytApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    return MaterialApp(
      title: 'TYT',
      theme: tytTheme,
      home: auth.when(
        data: (status) => status == AuthStatus.signedIn
            ? const _HomeScreen()
            : const LoginScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const _StartupErrorScreen(),
      ),
    );
  }
}

/// 출발 조회 화면이 들어올 자리.
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('로그인했어요')));
  }
}

class _StartupErrorScreen extends ConsumerWidget {
  const _StartupErrorScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('서버에 연결할 수 없어요'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => ref.invalidate(authControllerProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }
}
