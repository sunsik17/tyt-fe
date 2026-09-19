import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../theme/tyt_colors.dart';
import '../theme/tyt_theme.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  var _busy = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).login();
    } catch (e) {
      _error = _messageFor(e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static String _messageFor(Object e) {
    if (e is DioException) {
      if (errorCode(e) == 'INVALID_SOCIAL_TOKEN') return '카카오 로그인을 다시 해주세요.';
      if (e.response == null) return '서버에 연결할 수 없어요. 잠시 후 다시 시도해 주세요.';
    }
    return '로그인하지 못했어요. 잠시 후 다시 시도해 주세요.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'tyt',
                style: TytTextStyles.number.copyWith(color: TytColors.ink),
              ),
              const SizedBox(height: 12),
              Text(
                '출발까지 남은 시간을 알려드려요',
                style: TytTextStyles.message.copyWith(color: TytColors.muted),
              ),
              const Spacer(),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: TytTextStyles.caption.copyWith(color: TytColors.ink),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              _KakaoLoginButton(onPressed: _busy ? null : _login, busy: _busy),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카카오 로그인 디자인 가이드의 색: 컨테이너 #FEE500, 레이블 검정 85%.
/// 카카오 심볼은 공식 리소스를 받아 넣어야 해서 아직 없다.
class _KakaoLoginButton extends StatelessWidget {
  const _KakaoLoginButton({required this.onPressed, required this.busy});

  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    const label = Color(0xD9000000);
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: label,
          disabledBackgroundColor: const Color(0xFFFEE500),
          disabledForegroundColor: label,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: busy
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: label),
              )
            : const Text('카카오 로그인', style: TytTextStyles.itemName),
      ),
    );
  }
}
