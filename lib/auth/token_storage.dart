import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Tokens {
  const Tokens({required this.accessToken, required this.refreshToken});

  factory Tokens.fromJson(Map<String, dynamic> json) => Tokens(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String,
  );

  final String accessToken;
  final String refreshToken;
}

abstract interface class TokenStorage {
  Future<Tokens?> read();
  Future<void> save(Tokens tokens);
  Future<void> clear();
}

/// iOS Keychain, Android Keystore 기반 암호화 저장소에 두 토큰을 둔다 (api-guide.md 토큰).
class SecureTokenStorage implements TokenStorage {
  static const _accessKey = 'accessToken';
  static const _refreshKey = 'refreshToken';

  final _storage = const FlutterSecureStorage();

  @override
  Future<Tokens?> read() async {
    final access = await _storage.read(key: _accessKey);
    final refresh = await _storage.read(key: _refreshKey);
    if (access == null || refresh == null) return null;
    return Tokens(accessToken: access, refreshToken: refresh);
  }

  @override
  Future<void> save(Tokens tokens) async {
    await _storage.write(key: _accessKey, value: tokens.accessToken);
    await _storage.write(key: _refreshKey, value: tokens.refreshToken);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
