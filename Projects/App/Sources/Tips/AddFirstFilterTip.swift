import TipKit
import SwiftUI

struct AddFirstFilterTip: Tip {
	let analyticsManager: AnalyticsManager

	init(analyticsManager: AnalyticsManager = .shared) {
		self.analyticsManager = analyticsManager
	}

	// 필터 개수를 추적하는 Parameter
	@Parameter
	static var hasFilters: Bool = false

	// 현재 launch에서 팁이 표시되었는지 추적 (transient - 앱 재실행 시 자동 초기화)
	@Parameter(.transient)
	static var shownThisLaunch: Bool = false

	var title: Text {
		Text("title_add_rule_tip", bundle: .main)
	}

	var message: Text? {
		Text("message_add_rule_tip", bundle: .main)
	}

	// var image: Image? {
	//     Image(systemName: "plus.circle.fill")
	// }

	var actions: [Action] {
		[Action(id: "add_filter", title: "rules.add".localized())]
	}

	// 필터가 없고 이번 launch에서 아직 표시되지 않았을 때만 팁 표시
	var rules: [Rule] {
		[
			#Rule(Self.$hasFilters) { $0 == false },
			#Rule(Self.$shownThisLaunch) { $0 == false }
		]
	}

	// 매번 표시되도록 설정
	var options: [TipOption] {
		[
			Tips.MaxDisplayCount(100),
			Tips.IgnoresDisplayFrequency(true)
		]
	}

	func logShown(isFirstLaunch: Bool = false) {
		analyticsManager.logTipShown(
			tipId: AnalyticsManager.TipID.addFirstFilter,
			isFirstLaunch: isFirstLaunch
		)
	}

	func logActionTaken() {
		// 사용자가 액션을 취했을 때 이번 launch에서 더 이상 표시하지 않음
		Self.shownThisLaunch = true
		analyticsManager.logTipActionTaken(
			tipId: AnalyticsManager.TipID.addFirstFilter,
			actionType: "add_first_filter"
		)
	}
}
