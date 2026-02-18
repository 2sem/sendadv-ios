import TipKit
import SwiftUI

struct AddRuleTip: Tip {
	let analyticsManager: AnalyticsManager

	init(analyticsManager: AnalyticsManager = .shared) {
		self.analyticsManager = analyticsManager
	}

	var title: Text {
		Text("title_add_rule_tip", bundle: .main)
	}

	var message: Text? {
		Text("message_add_rule_tip", bundle: .main)
	}

	// var image: Image? {
	//     Image(systemName: "plus.circle.fill")
	// }

	func logShown(isFirstLaunch: Bool = false) {
		analyticsManager.logTipShown(
			tipId: AnalyticsManager.TipID.addRule,
			isFirstLaunch: isFirstLaunch
		)
	}

	func logActionTaken() {
		analyticsManager.logTipActionTaken(
			tipId: AnalyticsManager.TipID.addRule,
			actionType: "add_rule"
		)
	}
}
