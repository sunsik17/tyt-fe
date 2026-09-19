import 'package:dio/dio.dart';
import 'package:tyt/auth/auth_api.dart';
import 'package:tyt/auth/kakao_login.dart';
import 'package:tyt/auth/token_storage.dart';

class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage([this.tokens]);

  Tokens? tokens;

  @override
  Future<Tokens?> read() async => tokens;

  @override
  Future<void> save(Tokens tokens) async => this.tokens = tokens;

  @override
  Future<void> clear() async => tokens = null;
}

class FakeKakaoLogin implements KakaoLogin {
  FakeKakaoLogin(this.accessToken);

  /// null이면 사용자가 취소한 것이다.
  final String? accessToken;

  @override
  Future<String?> login() async => accessToken;
}

class FakeAuthApi implements AuthApi {
  FakeAuthApi({this.getMeError, this.loginTokens});

  final Object? getMeError;
  final Tokens? loginTokens;
  var getMeCalls = 0;
  final loginCalls = <String>[];

  @override
  Future<void> getMe() async {
    getMeCalls++;
    if (getMeError != null) throw getMeError!;
  }

  @override
  Future<Tokens> loginWithKakao(String kakaoAccessToken) async {
    loginCalls.add(kakaoAccessToken);
    return loginTokens!;
  }
}

/// 서버의 실패 응답 봉투를 담은 DioException.
DioException apiError(int status, String code) {
  final options = RequestOptions(path: '/');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: options,
      statusCode: status,
      data: {'code': code, 'message': '', 'data': null},
    ),
  );
}
