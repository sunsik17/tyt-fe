---
paths:
  - "**/*"
---

# API (서버 연동)

원본 규칙은 tyt-be의 `.claude/rules/api.md`에 있다. 여기에는 FE가 알아야 할 부분만 적는다. 서버 구현 규칙(Controller, 예외 처리)은 옮겨오지 않는다.

## URL

- 클라이언트가 호출하는 경로는 `/api/v1/<resources>`. 리소스는 복수형 kebab-case 명사 (`/api/v1/user-settings`).
- 동사 대신 하위 리소스로 표현한다: `PATCH /api/v1/matchings/{id}/approval`
- `/internal/v1`은 서비스 간 내부 호출용이다. 클라이언트는 호출하지 않는다.
- 버전은 breaking change가 있을 때만 올라간다. 앱을 v1에 둔 채 v2를 병행 배포하기 위한 장치다.

## 응답

- 성공·실패 모두 `ApiResponse` 봉투로 감싸서 온다.
- 실패는 도메인별 ErrorCode(ErrorType + 메시지)를 담고, HTTP status는 서버에서 ErrorType으로부터 변환된다.

**봉투의 실제 필드 구조는 아직 확정되지 않았다.** 서버에 엔드포인트가 하나도 없는 상태다. 엔드포인트가 생기면 이 문서를 늘리지 말고 서버가 내보내는 OpenAPI 스펙을 본다. 여기에 스펙을 베껴두면 실제 API와 어긋난다.
