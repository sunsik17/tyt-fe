import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tyt/theme/tyt_colors.dart';
import 'package:tyt/theme/tyt_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('버튼·선택 상태 색은 상태 색이 아니라 잉크다', () {
    expect(tytTheme.colorScheme.primary, TytColors.ink);
  });

  test('앱 바탕은 뉴트럴 ground이고 기본 글꼴은 고딕 A1이다', () {
    expect(tytTheme.scaffoldBackgroundColor, TytColors.ground);
    expect(tytTheme.textTheme.bodyMedium!.fontFamily, TytFonts.sans);
  });

  test('pubspec.yaml에 등록한 글꼴과 라이선스 파일이 모두 번들된다', () async {
    const assets = [
      'assets/fonts/GowunDodum/GowunDodum-Regular.ttf',
      'assets/fonts/GothicA1/GothicA1-Regular.ttf',
      'assets/fonts/GothicA1/GothicA1-Medium.ttf',
      'assets/fonts/GothicA1/GothicA1-Bold.ttf',
      'assets/fonts/RedHatMono/RedHatMono-VariableFont_wght.ttf',
      'assets/fonts/GowunDodum/OFL.txt',
      'assets/fonts/GothicA1/OFL.txt',
      'assets/fonts/RedHatMono/OFL.txt',
    ];
    for (final path in assets) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(0), reason: path);
    }
  });
}
