import TipKit
import SwiftUI

struct AddFirstFilterTip: Tip {
	let analyticsManager: AnalyticsManager

	init(analyticsManager: AnalyticsManager = .shared) {
		self.analyticsManager = analyticsManager
	}

	var title: Text {
		Text("tip.addFilter.title".localized())
	}

	var message: Text? {
		Text("tip.addFilter.message".localized())
	}

	var image: Image? {
		Image(systemName: "plus.circle.fill")
	}

	var actions: [Action] {
		[Action(id: "add_filter", title: "tip.addFilter.action".localized())]
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
			actionType: "add_filter"
		)
	}
}
