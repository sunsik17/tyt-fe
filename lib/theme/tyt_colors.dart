import 'package:flutter/painting.dart';

/// docs/design.md의 컬러.
abstract final class TytColors {
  // 상태 척도. 출발까지 남은 분이 줄어드는 순서다.
  static const sky = Color(0xFFE8F0FA); // 준비 시간 초과
  static const skyDeep = Color(0xFFD9E6F7); // 15분 ~ 준비 시간
  static const cobalt = Color(0xFF2F55C8); // 5–14분. 아이덴티티 컬러
  static const night = Color(0xFF101B3B); // 0–4분, −1 ~ −2분
  static const tangerine = Color(0xFFFF8A4C); // 출발 시각이 지났을 때만 쓴다

  // 뉴트럴. 기록·일정 만들기 화면과 버튼·선택 상태에 쓴다.
  static const ink = Color(0xFF101B3B);
  static const ground = Color(0xFFF4F6FA);
  static const card = Color(0xFFFFFFFF);
  static const muted = Color(0xFF5A6379);
  static const line = Color(0xFFE3E7EF);
}
