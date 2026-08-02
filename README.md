# 새벽 여섯 시 — 배포 순서

빌드 도구 없음. 파일 5개가 전부입니다. 순서대로 15분이면 끝납니다.

---

## 1단계 · Supabase (5분)

1. supabase.com 로그인 → 프로젝트 선택 (없으면 New project)
2. 왼쪽 메뉴 **SQL Editor** → New query
3. `supabase-schema.sql` 내용을 통째로 붙여넣고 **Run**
4. 왼쪽 메뉴 **Project Settings → API** 로 이동해서 두 값을 복사해 둡니다
   - **Project URL** (https://xxxx.supabase.co)
   - **anon public** key (eyJ... 로 시작하는 긴 문자열)

> anon key는 공개돼도 되는 키입니다. RLS가 걸려 있어 본인 계정 데이터만 접근됩니다.

---

## 2단계 · Vercel 배포 (5분)

**방법 A — 드래그 앤 드롭 (가장 빠름)**
1. 이 폴더를 압축 해제한 상태로 준비
2. vercel.com/new → 아래쪽 "Deploy without Git" 또는 폴더 드래그
3. 배포되면 `https://xxxx.vercel.app` 주소가 나옵니다

**방법 B — GitHub 연동 (수정이 잦을 때)**
1. GitHub에 새 저장소를 만들고 이 파일들을 올립니다
2. vercel.com/new → 그 저장소 선택 → Deploy
3. 프레임워크는 **Other**, 빌드 명령은 비워둡니다

---

## 3단계 · 앱 연결 (2분)

1. 배포된 주소를 폰 Safari로 엽니다
2. 아래 **설정** 탭 → Project URL, anon key 붙여넣고 **저장하고 연결**
3. 이메일 입력 → **로그인 링크 받기** → 메일함의 링크 클릭
4. 상단에 "클라우드 저장됨"이 뜨면 완료

---

## 4단계 · 홈 화면에 추가 (1분)

Safari에서 공유 버튼 → **홈 화면에 추가**
아이콘으로 열리고, 주소창 없이 앱처럼 뜹니다.

---

## 기록은 어떻게 저장되나

- 입력하는 즉시 **브라우저에 저장** (인터넷 없어도 됨)
- 로그인돼 있으면 **Supabase에도 자동 백업** (기기가 바뀌어도 따라옴)
- 설정 탭의 백업/복원으로 텍스트 내보내기도 가능

기존 기록을 옮기려면 설정 탭 텍스트 칸에 붙여넣고 "붙여넣기 복원"을 누르면 됩니다.

---

## 7/31 기록 (첫날)

아래를 설정 탭에 붙여넣으면 첫날 기록이 복원됩니다.

```json
{"2026-07-31":{"sets":{"leg":[true,true,false],"chest":[true,true,false]},"weights":{"leg":"20","chest":"10"},"yoga":{"part":null,"done":false},"meals":{"egg":3,"yogurt":1,"meal":1,"profit":1},"bodyWeight":"75.1","arrived":true,"backup":false}}
```

---

## 파일 설명

| 파일 | 역할 |
|---|---|
| index.html | 앱 전체 (화면·로직·차트) |
| manifest.webmanifest | 홈 화면 아이콘·앱 이름 |
| sw.js | 오프라인 캐시 |
| icon-192.png / icon-512.png | 아이콘 |
| supabase-schema.sql | 테이블·보안정책 |

---

## 막히면

- 로그인 링크가 안 오면 → Supabase **Authentication → Providers → Email** 이 켜져 있는지 확인
- 링크를 눌렀는데 안 열리면 → **Authentication → URL Configuration**의 Site URL에 Vercel 주소 추가
- 저장이 안 되면 → 설정 탭 상단 상태 표시를 확인 ("클라우드 저장됨" / "로컬 저장")
