# 😂 DadJoke - 아재개그 앱

한국 아재개그를 랜덤으로 보여주는 iOS 앱입니다.

## ✨ 주요 기능

- 📱 **랜덤 개그**: 아재개그를 랜덤으로 표시
- 🔖 **북마크**: 마음에 드는 개그를 저장
- ➕ **개그 추가**: 사용자가 직접 개그 제출 가능
- 📅 **일일 추적**: 오늘 본 개그는 다시 표시되지 않음 (매일 자정 리셋)
- ☁️ **Supabase 연동**: 실시간 데이터 동기화

## 🛠 기술 스택

- **언어**: Swift
- **UI**: SwiftUI
- **데이터베이스**: Supabase (PostgreSQL)
- **아키텍처**: MVVM 패턴
- **의존성 관리**: Swift Package Manager

## 🚀 시작하기

### 1. 프로젝트 클론

```bash
git clone https://github.com/YOUR_USERNAME/DadJoke.git
cd DadJoke
```

### 2. Supabase 설정

#### 2-1. Supabase 프로젝트 생성

1. [Supabase](https://supabase.com) 가입/로그인
2. "New Project" 클릭
3. 프로젝트 이름, 데이터베이스 비밀번호 설정
4. 리전 선택 후 생성

#### 2-2. 데이터베이스 테이블 생성

Supabase SQL Editor에서 다음 SQL 실행:

```sql
-- 1. 기존 RLS 정책 먼저 삭제 (status 컬럼 의존성 제거)
DROP POLICY IF EXISTS "Anyone can read approved gags" ON gags;
DROP POLICY IF EXISTS "Anyone can insert pending gags" ON gags;
DROP POLICY IF EXISTS "Anyone can insert gags" ON gags;
DROP POLICY IF EXISTS "Anyone can read gags" ON gags;

-- 2. 이제 status 컬럼 삭제 가능
ALTER TABLE gags DROP COLUMN IF EXISTS status;

-- 3. gags 테이블 읽기 정책 생성 (누구나 읽기 가능)
CREATE POLICY "Anyone can read gags" ON gags
  FOR SELECT USING (true);

-- 4. pending_gags 테이블 생성 (승인 대기 개그)
CREATE TABLE IF NOT EXISTS pending_gags (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. pending_gags RLS 활성화
ALTER TABLE pending_gags ENABLE ROW LEVEL SECURITY;

-- 6. 누구나 pending_gags에 추가 가능
CREATE POLICY "Anyone can insert pending gags" ON pending_gags
  FOR INSERT WITH CHECK (true);

-- 7. 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_pending_gags_created_at ON pending_gags(created_at DESC);
```

### 3. 환경 변수 설정

#### 3-1. API 키 확인

Supabase 대시보드에서:
1. **Settings** → **API** 메뉴
2. **Project URL** 복사 (예: `https://xxxxx.supabase.co`)
3. **anon/public** 키 복사

#### 3-2. Config.xcconfig 파일 생성

```bash
# 템플릿 파일 복사
cp Config.xcconfig.template Config.xcconfig

# Config.xcconfig 파일 편집
# YOUR_PROJECT_ID와 YOUR_ANON_PUBLIC_KEY_HERE를 실제 값으로 교체
```

**Config.xcconfig 예시:**
```
SUPABASE_URL = https:/$()/xxxxx.supabase.co
SUPABASE_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 4. Xcode 설정

#### 4-1. 프로젝트 열기

```bash
open DadJoke.xcodeproj
```

#### 4-2. Config.xcconfig 연결

1. Xcode에서 프로젝트 파일 선택
2. **PROJECT** → **DadJoke** 선택
3. **Info** 탭으로 이동
4. **Configurations** 섹션에서:
   - **Debug**: `Config` 선택
   - **Release**: `Config` 선택

**또는 수동 연결:**

1. Xcode에서 `Config.xcconfig` 파일을 프로젝트에 드래그
2. **Copy items if needed** 체크하지 않음 (참조만)
3. **Add to targets** 체크 해제

#### 4-3. Build Settings 확인

1. **PROJECT** → **DadJoke** → **Build Settings**
2. 검색: "User-Defined"
3. 다음 값들이 보여야 함:
   - `SUPABASE_URL`
   - `SUPABASE_KEY`

### 5. 빌드 및 실행

```bash
# Command Line
xcodebuild -project DadJoke.xcodeproj -scheme DadJoke -destination 'platform=iOS Simulator,name=iPhone 15' build

# 또는 Xcode에서
# Cmd + R
```

## 📂 프로젝트 구조

```
DadJoke/
├── DadJoke/
│   ├── DadJokeApp.swift          # 앱 진입점
│   ├── Config.swift               # 환경 변수 관리
│   ├── SupabaseClient.swift      # Supabase 클라이언트
│   ├── GagModel.swift             # 개그 데이터 모델 & API
│   ├── UserDataManager.swift     # 로컬 데이터 관리 (북마크, 본 개그)
│   ├── MainTabView.swift          # 메인 탭 뷰
│   ├── ContentView.swift          # 홈 화면
│   ├── BookmarkView.swift         # 북마크 화면
│   └── AddGagView.swift           # 개그 추가 화면
├── Config.xcconfig                # 환경 변수 (gitignore)
├── Config.xcconfig.template       # 환경 변수 템플릿
├── SUPABASE_GUIDE.md             # Supabase 관리 가이드
└── README.md                      # 이 파일
```

## 🔐 보안

- ✅ API 키는 `Config.xcconfig`에 저장 (gitignore 처리됨)
- ✅ Supabase Row Level Security (RLS) 활성화
- ✅ 환경 변수로 민감 정보 관리

**주의**: `Config.xcconfig` 파일은 절대 GitHub에 푸시하지 마세요!

## 📝 개그 관리

제출된 개그 승인 방법은 [SUPABASE_GUIDE.md](./SUPABASE_GUIDE.md) 참고

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다.

## 📧 연락처

프로젝트 링크: [https://github.com/YOUR_USERNAME/DadJoke](https://github.com/YOUR_USERNAME/DadJoke)

---

**Made with ❤️ by SpartaCoding iOS26**
