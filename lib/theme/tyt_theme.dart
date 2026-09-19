import 'package:flutter/material.dart';

import 'tyt_colors.dart';

/// pubspec.yaml에 등록한 글꼴 family 이름.
abstract final class TytFonts {
  static const display = 'GowunDodum';
  static const sans = 'GothicA1';
  static const mono = 'RedHatMono';
}

/// docs/design.md의 타이포그래피.
abstract final class TytTextStyles {
  // 고운돋움은 굵기가 400 하나뿐이라 위계는 크기로만 나눈다.
  static const number = TextStyle(
    fontFamily: TytFonts.display,
    fontSize: 92,
    height: 1,
    letterSpacing: -3.68, // -0.04em
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const message = TextStyle(
    fontFamily: TytFonts.display,
    fontSize: 22,
    height: 1.35,
  );
  static const title = TextStyle(fontFamily: TytFonts.display, fontSize: 24);

  static const body = TextStyle(
    fontFamily: TytFonts.sans,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
  static const itemName = TextStyle(
    fontFamily: TytFonts.sans,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );
  static const caption = TextStyle(
    fontFamily: TytFonts.sans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Red Hat Mono는 가변 글꼴이라 fontWeight가 아니라 wght 축으로 굵기를 정한다.
  static const time = TextStyle(
    fontFamily: TytFonts.mono,
    fontSize: 13,
    fontVariations: [FontVariation('wght', 500)],
    fontFeatures: [FontFeature.tabularFigures()],
  );
  static const tick = TextStyle(
    fontFamily: TytFonts.mono,
    fontSize: 10,
    fontVariations: [FontVariation('wght', 400)],
  );
}

/// 버튼과 선택 상태는 잉크로 칠한다. 상태 색은 여유를 보여줄 때만 쓴다.
final tytTheme = ThemeData(
  fontFamily: TytFonts.sans,
  scaffoldBackgroundColor: TytColors.ground,
  colorScheme: const ColorScheme.light(
    primary: TytColors.ink,
    onPrimary: TytColors.card,
    surface: TytColors.card,
    onSurface: TytColors.ink,
    outline: TytColors.line,
  ),
);
