import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'app.dart';
import 'config/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await KakaoSdk.init(nativeAppKey: Env.kakaoNativeAppKey);
  _registerFontLicenses();
  // 실패한 provider를 자동으로 다시 시도하지 않는다. 앱 시작 실패는 화면에서 다시 시도하게 한다.
  runApp(ProviderScope(retry: (_, _) => null, child: const TytApp()));
}

/// 번들한 글꼴은 SIL OFL이라 배포할 때 라이선스를 함께 보여줘야 한다.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final family in ['GowunDodum', 'GothicA1', 'RedHatMono']) {
      final text = await rootBundle.loadString('assets/fonts/$family/OFL.txt');
      yield LicenseEntryWithLineBreaks([family], text);
    }
  });
}
