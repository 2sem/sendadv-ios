---
trigger: always_on
description: Your are
---

Your are partner senior iOS developer.
respond in korean always.

# iOS 프로젝트 개발 규칙

## 코딩 스타일
- Swift 코드는 Swift 6.0+ 문법을 사용
- 들여쓰기는 Tab 사용
- 변수명과 함수명은 camelCase 사용
- 클래스명과 구조체명은 PascalCase 사용
- 상수는 let 키워드 사용, 변수는 var 키워드 사용

## Platform
- iOS만 지원
- 최소 지원 iOS 18 이상

## 아키텍처 패턴
- MVVM 패턴 준수
- 싱글톤 패턴은 필요한 경우에만 사용

## UI 개발
- SwiftUI 기반 개발
- Navigation은 NavigationView 대신 NavigationStack 사용
- 하드코딩된 값 대신 상수 사용
- 접근성(Accessibility) 고려

## 메모리 관리
- ARC(Automatic Reference Counting) 활용
- 강한 참조 순환(Strong Reference Cycle) 방지
- weak, unowned 키워드 적절히 사용

## 에러 처리
- do-catch 문을 사용한 에러 처리
- Optional 타입 적절히 활용
- guard 문을 사용한 조기 반환

## 성능 최적화
- 불필요한 객체 생성 최소화
- 이미지 캐싱 고려
- 네트워크 요청 최적화

## 보안
- API 키 하드코딩 금지
- 사용자 데이터 보호
- HTTPS 통신 사용

## 테스트
- Unit Test 작성 권장
- UI Test 필요시 작성
- 테스트 가능한 코드 구조 설계

## 이름
- ViewController에 해당하는 전체 View는 Screen으로 끝냄
- Screen내 하위 View는 View로 끝냄

## 파일
### 화면
1. 스플래시 화면
- name: 스플래시 화면 / SplashScreen
- file: Projects/App/Sources/Screens/SplashScreen.swift
- view model: DataMigrationManager (내장 @StateObject)
- description: 앱 시작 시 데이터 마이그레이션 처리

2. 규칙 목록 화면
- name: 규칙 목록 화면 / RecipientRuleListScreen
- file: Projects/App/Sources/Screens/RecipientList/RecipientRuleListScreen.swift
- view model: Projects/App/Sources/ViewModels/RecipientListScreenModel.swift

3. 규칙 상세 화면
- name: 규칙 상세 화면 / RuleDetailScreen
- file: Projects/App/Sources/Screens/RuleDetailScreen.swift
- view model: Projects/App/Sources/ViewModels/RuleDetailScreenModel.swift
- description: 수신자 규칙 편집 (직책/부서/조직 필터 설정)

4. 규칙 필터 화면
- name: 규칙 필터 화면 / RuleFilterScreen
- file: Projects/App/Sources/Screens/RuleFilterScreen.swift
- view model: Projects/App/Sources/ViewModels/RuleFilterScreenModel.swift
- description: 필터 항목 선택 (직책/부서/조직)

5. 앱 시작 지점
- name: SendadvIosApp
- file: sendadv-ios/Sources/SendadvIosApp.swift
- view model: 없음
- description: @main 앱 진입점

# 패치 안전성(Safe Patch) 규칙

# 금지 사항
- 코드에 요약/프리뷰 마커 삽입 금지: `{{ ... }}`, `...`, `<snip>` 등 어떠한 형태도 코드 본문에 넣지 않는다.
- 현지화 목적 외 구조 변경 금지: 레이아웃, 제스처, 제어 흐름(guard/if/switch), 함수 시그니처 변경 금지.

# 구문 무결성
- Swift 구문 보존: 여는/닫는 중괄호, 괄호, 제네릭 꺾쇠 균형을 깨지 않는다.
- ViewBuilder 블록(예: `.toolbar {}`, `.sheet {}`, `.if {}`)의 범위를 변경하지 않는다.

# 변경 범위
- 사용자 노출 텍스트만 교체: `"문자열"` → `"Key".localized()` 또는 기존 키 재사용.
- `Label`, `Alert`, `TextField` 등의 인자 순서를 바꾸지 않는다.

# 패치 작성 지침
- 각 변경 헝크에 최소 3줄의 전후 컨텍스트를 포함한다(파일 내 고유 식별 가능).
- 여러 비인접 변경은 하나의 패치에 다중 헝크로 기술한다(파일 전체 교체 금지).
- 시각적 주석/마커(`{{ ... }}` 등)와 자동 요약을 패치 본문에 포함하지 않는다.

# 사후 검증
- 수정 직후 파일을 다시 열어 `{{ ... }}` 등이 삽입되지 않았는지 확인한다.
- 가능하면 빌드/타입체크를 수행해 컴파일 오류가 없는지 확인한다.