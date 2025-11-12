# DadJoke 앱 - Supabase 관리 가이드

이 문서는 DadJoke 앱의 Supabase 데이터베이스 관리 방법을 설명합니다.

## 📊 데이터베이스 구조

### 1. `gags` 테이블 (승인된 개그)
- **용도**: 앱에 표시되는 승인된 개그
- **권한**: 읽기 전용 (앱에서 조회만 가능)
- **컬럼**:
  - `id` (BIGSERIAL): 고유 ID
  - `title` (TEXT): 개그 질문
  - `content` (TEXT): 개그 답변
  - `category` (TEXT): 카테고리 (동물, 음식, 일상, 말장난, 기타)
  - `created_at` (TIMESTAMP): 생성 시간

### 2. `pending_gags` 테이블 (승인 대기 개그)
- **용도**: 사용자가 제출한 개그 (승인 대기 중)
- **권한**: 쓰기 가능 (앱에서 추가 가능), 앱에서는 보이지 않음
- **컬럼**: `gags` 테이블과 동일

---

## 🔐 Supabase 프로젝트 정보

- **프로젝트 ID**: `[REDACTED]` (보안상 비공개)
- **접속 방법**: Supabase 대시보드 로그인 후 프로젝트 선택

---

## 📝 개그 승인 프로세스

### 단계 1: 승인 대기 개그 확인

1. Supabase 대시보드 접속
2. **Table Editor** 메뉴 클릭
3. **`pending_gags`** 테이블 선택
4. 제출된 개그 목록 확인

### 단계 2: 개그 승인하기 (권장 방법)

**SQL Editor 사용:**

1. **SQL Editor** 메뉴 클릭
2. 다음 SQL 실행:

```sql
-- 1. 승인하려는 개그의 ID 확인 (예: id = 1)

-- 2. gags 테이블로 복사
INSERT INTO gags (title, content, category)
SELECT title, content, category
FROM pending_gags
WHERE id = 1;  -- 👈 승인할 개그 ID로 변경

-- 3. pending_gags에서 삭제
DELETE FROM pending_gags WHERE id = 1;  -- 👈 동일한 ID
```

**여러 개그 한 번에 승인:**

```sql
-- ID 1, 2, 3을 한 번에 승인
INSERT INTO gags (title, content, category)
SELECT title, content, category
FROM pending_gags
WHERE id IN (1, 2, 3);  -- 👈 승인할 ID들

DELETE FROM pending_gags WHERE id IN (1, 2, 3);
```

### 단계 3: 개그 거부하기

승인하지 않을 개그는 `pending_gags`에서 삭제만 하면 됩니다:

```sql
-- ID 5를 거부 (삭제)
DELETE FROM pending_gags WHERE id = 5;
```

또는 Table Editor에서:
1. `pending_gags` 테이블로 이동
2. 거부할 개그 행 선택
3. Delete 버튼 클릭

---

## 🔍 유용한 SQL 쿼리

### 모든 승인 대기 개그 확인
```sql
SELECT * FROM pending_gags ORDER BY created_at DESC;
```

### 카테고리별 승인 대기 개그 확인
```sql
SELECT * FROM pending_gags
WHERE category = '동물'
ORDER BY created_at DESC;
```

### 최근 승인된 개그 확인
```sql
SELECT * FROM gags
ORDER BY created_at DESC
LIMIT 10;
```

### 카테고리별 개그 개수 확인
```sql
-- 승인된 개그
SELECT category, COUNT(*) as count
FROM gags
GROUP BY category;

-- 대기 중인 개그
SELECT category, COUNT(*) as count
FROM pending_gags
GROUP BY category;
```

### 새 개그 직접 추가 (SQL로)
```sql
INSERT INTO gags (title, content, category) VALUES
  ('새로운 질문?', '새로운 답변!', '일상');
```

---

## 🛠️ 테이블 관리

### 승인 대기 개그 모두 삭제 (초기화)
```sql
TRUNCATE TABLE pending_gags RESTART IDENTITY;
```

### 특정 카테고리 개그만 삭제
```sql
DELETE FROM gags WHERE category = '기타';
```

### 개그 수정
```sql
-- ID 10번 개그의 내용 수정
UPDATE gags
SET content = '수정된 답변!'
WHERE id = 10;
```

---

## 📊 데이터 백업

### CSV로 내보내기
1. Table Editor에서 테이블 선택
2. 상단의 **"..."** 메뉴 클릭
3. **"Download as CSV"** 선택

### SQL로 백업
```sql
-- 모든 데이터 조회 (복사 후 저장)
SELECT * FROM gags ORDER BY id;
```

---

## ⚠️ 주의사항

1. **gags 테이블 직접 수정 시**: 앱에 즉시 반영됨 (캐싱 없음)
2. **RLS 정책**: 실수로 삭제하지 않도록 주의
3. **ID 충돌**: `pending_gags`에서 `gags`로 복사 시 ID는 자동 생성됨

---

## 🔧 문제 해결

### 앱에서 개그가 안 보일 때
1. `gags` 테이블에 데이터가 있는지 확인
2. RLS 정책 확인:
```sql
-- 정책 확인
SELECT * FROM pg_policies WHERE tablename = 'gags';

-- 정책이 없다면 재생성
CREATE POLICY "Anyone can read gags" ON gags
  FOR SELECT USING (true);
```

### 개그 제출이 안 될 때
1. `pending_gags` 테이블 존재 확인
2. INSERT 정책 확인:
```sql
CREATE POLICY "Anyone can insert pending gags" ON pending_gags
  FOR INSERT WITH CHECK (true);
```

---

## 📱 앱 연동 정보

### API 키 확인
- Settings > API > Project API keys
- `anon/public` 키 사용 중

### 연결 테스트
```sql
-- 간단한 테스트 쿼리
SELECT COUNT(*) as total_gags FROM gags;
SELECT COUNT(*) as pending_gags FROM pending_gags;
```

---

## 📚 참고 자료

- [Supabase 공식 문서](https://supabase.com/docs)
- [PostgreSQL 문법](https://www.postgresql.org/docs/)
- [Row Level Security 가이드](https://supabase.com/docs/guides/auth/row-level-security)

---

**마지막 업데이트**: 2025-01-11
