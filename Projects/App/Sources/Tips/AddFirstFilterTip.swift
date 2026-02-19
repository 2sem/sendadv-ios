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

	// 필터가 없을 때만 팁 표시
	var rules: [Rule] {
		[
			#Rule(Self.$hasFilters) { $0 == false }
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
		analyticsManager.logTipActionTaken(
			tipId: AnalyticsManager.TipID.addFirstFilter,
			actionType: "add_first_filter"
		)
	}
}
