import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/tyt_theme.dart';

void main() {
  _registerFontLicenses();
  runApp(const TytApp());
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

class TytApp extends StatelessWidget {
  const TytApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TYT',
      theme: tytTheme,
      home: const Scaffold(body: Center(child: Text('TYT'))),
    );
  }
}
