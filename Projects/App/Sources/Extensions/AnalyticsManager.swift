//
//  AnalyticsManager.swift
//  App
//

import Foundation
import FirebaseAnalytics

// MARK: - AnalyticsManager

final class AnalyticsManager {
	static let shared = AnalyticsManager()

	private init() {}

	// MARK: - Event Names

	enum Event {
		static let tipShown = "tip_shown"
		static let tipActionTaken = "tip_action_taken"
		static let tipDismissed = "tip_dismissed"
	}

	// MARK: - Parameter Keys

	enum Param {
		static let tipId = "tip_id"
		static let isFirstLaunch = "is_first_launch"
		static let actionType = "action_type"
		static let dismissMethod = "dismiss_method"
	}

	// MARK: - Tip IDs

	enum TipID {
		static let addFirstFilter = "add_first_filter"
		static let addRule = "add_rule"
	}

	// MARK: - Log Methods

	/// TipKit 팝업이 화면에 표시됐을 때 호출
	func logTipShown(tipId: String, isFirstLaunch: Bool = false) {
		Analytics.logEvent(Event.tipShown, parameters: [
			Param.tipId: tipId,
			Param.isFirstLaunch: isFirstLaunch
		])
	}

	/// 사용자가 TipKit 액션 버튼을 눌렀을 때 호출
	func logTipActionTaken(tipId: String, actionType: String) {
		Analytics.logEvent(Event.tipActionTaken, parameters: [
			Param.tipId: tipId,
			Param.actionType: actionType
		])
	}

	/// 사용자가 TipKit을 닫았을 때 호출 (옵션)
	func logTipDismissed(tipId: String, dismissMethod: String = "close") {
		Analytics.logEvent(Event.tipDismissed, parameters: [
			Param.tipId: tipId,
			Param.dismissMethod: dismissMethod
		])
	}
}
