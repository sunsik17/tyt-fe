---
paths:
  - "**/*"
---

# API (서버 연동)

원본 규칙은 tyt-be의 `.claude/rules/api.md`에 있다. 여기에는 FE가 알아야 할 부분만 적는다. 서버 구현 규칙(Controller, 예외 처리)은 옮겨오지 않는다.

## 문서

서버 API는 tyt-be의 문서 두 개를 본다. **복사해오지 않는다.** 복사본은 원본이 바뀌는 순간 틀려진다.

| 무엇을 | 어디서 |
| --- | --- |
| 엔드포인트별 요청·응답 필드, 에러 코드와 발생 조건, 인증 필요 여부 | `../tyt-be/docs/openapi.yaml` |
| 응답 봉투 규칙, 공통 에러, 날짜·시간 형식, 토큰 규칙, 로그인·401·재발급 흐름, 화면별로 쓰는 API | `../tyt-be/docs/api-guide.md` |

- API 연동 코드를 쓰기 전에 두 문서를 읽는다. 필드 이름, 에러 코드, 흐름을 추측하지 않는다.
- `openapi.yaml`은 BE 코드에서 생성되고, 코드와 다르면 BE 빌드가 실패하므로 최신이다. 로컬 서버를 띄웠다면 `http://localhost:8080/swagger-ui.html`에서도 볼 수 있다.
- `api-guide.md`는 빌드가 검사하지 않는다. 실제 동작이 문서와 다르면 추측으로 맞추지 말고 tyt-be에 이슈를 만든다.

## URL

- 클라이언트가 호출하는 경로는 `/api/v1/<resources>`. 리소스는 복수형 kebab-case 명사 (`/api/v1/user-settings`).
- 동사 대신 하위 리소스로 표현한다: `PATCH /api/v1/matchings/{id}/approval`
- `/internal/v1`은 서비스 간 내부 호출용이다. 클라이언트는 호출하지 않는다.
- 버전은 breaking change가 있을 때만 올라간다. 앱을 v1에 둔 채 v2를 병행 배포하기 위한 장치다.
