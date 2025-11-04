---
trigger: manual
description: Cursor 규칙 - 현지화(Localization)
---

## 현지화 원칙
- 하드코딩 문자열을 현지화 시 `"<Localized String Name>".localized()` 형태 사용
- Key 정의 언어: 영어
- 현지화 문자열 정의 경로:
  - `Projects/App/Resources/Strings/en.lproj/Localizable.strings`
  - `Projects/App/Resources/Strings/ko.lproj/Localizable.strings`
- 기존 현지화된 문자열 재사용 우선, 중복 키 생성 금지
- 현지화 문자열 이름: 원문의 뜻을 담되 간결하게(예: `"Rule Title"`, `"Enter rule title"`)
- 포맷 문자열은 `"<Formatted Localized String Name>".localized().asFormat(...)` 사용
- 현지화된 문자열은 빈 문자열만으로 구성될 수 없다.

## 예시
- View
  - `Text("Rule Title".localized())`
  - `TextField("Enter rule title".localized(), text: $title)`
  - `.navigationTitle("Edit Recipients Rule".localized())`
  - `Button("Save".localized()) { ... }`
- 접근성
  - `.accessibilityLabel("Save".localized())`
- 포맷
  - `Text("Recommend '%@'".localized().asFormat(...))`

## 현지화 예외
- 디버그/로그/프린트
- 테스트 코드의 하드코딩 문자열
- 사용자 비노출 내부 식별자/키
- 임시 실험 플래그(비노출)

## 리뷰 체크리스트
- [ ] 사용자 노출 문자열에 하드코딩 언어 없음
- [ ] 모든 문자열에 `.localized()` 적용
- [ ] 신규 키는 en/ko 모두 추가
- [ ] 기존 키 중복 생성 없음
- [ ] Placeholder/Title/Alert/Accessibility 누락 없음

## 작업 단계
1. 현지화 대상 파일에 현지화되지 않은 하드코딩 문자열이 있는지 확인
2. 현지화 대상 문자열 추출
3. 추출한 각 현지화 대상 문자열에 대한 현지화 문자열 이름을 정의
4. `Localizable.strings`에 신규 현지화된 문자열 정의
5. 현지화 대상 파일의 하드코딩 문자열을 신규 정의된 현지화된 문자열로 대체
6. 현지화 대상 파일에 현지화되지 않은 문자열이 남아있는지 확인


