import Foundation
import XCTest
@testable import App

final class SendHistoryRulesTests: XCTestCase {
	func test_status_allBatchesSent_isCompleted() {
		XCTAssertEqual(SendHistoryRules.status(sentCount: 40, totalCount: 40, outcome: .sent), .completed)
	}

	func test_status_midBatchSent_isPartial() {
		XCTAssertEqual(SendHistoryRules.status(sentCount: 20, totalCount: 40, outcome: .sent), .partial)
	}

	func test_status_cancelled() {
		XCTAssertEqual(SendHistoryRules.status(sentCount: 0, totalCount: 40, outcome: .cancelled), .cancelled)
		XCTAssertEqual(SendHistoryRules.status(sentCount: 20, totalCount: 40, outcome: .cancelled), .partial)
	}

	func test_status_failed() {
		XCTAssertEqual(SendHistoryRules.status(sentCount: 0, totalCount: 40, outcome: .failed), .failed)
		XCTAssertEqual(SendHistoryRules.status(sentCount: 20, totalCount: 40, outcome: .failed), .partial)
	}

	func test_updatedSentCount_onlySentAddsAndClamps() {
		XCTAssertEqual(SendHistoryRules.updatedSentCount(current: 20, batchCount: 20, totalCount: 30, outcome: .sent), 30)
		XCTAssertEqual(SendHistoryRules.updatedSentCount(current: 20, batchCount: 20, totalCount: 100, outcome: .cancelled), 20)
		XCTAssertEqual(SendHistoryRules.updatedSentCount(current: 0, batchCount: 20, totalCount: 100, outcome: .failed), 0)
	}

	func test_isSessionFinished() {
		XCTAssertFalse(SendHistoryRules.isSessionFinished(sentCount: 20, totalCount: 40, outcome: .sent))
		XCTAssertTrue(SendHistoryRules.isSessionFinished(sentCount: 40, totalCount: 40, outcome: .sent))
		XCTAssertTrue(SendHistoryRules.isSessionFinished(sentCount: 20, totalCount: 40, outcome: .cancelled))
	}

	func test_duplicate_matchesSameSetWithinWindow() {
		let a = UUID(), b = UUID()
		let now = Date()
		let entries = [
			(date: now.addingTimeInterval(-3600), filterIDs: [b, a], sentCount: 10),
			(date: now.addingTimeInterval(-7200), filterIDs: [a, b], sentCount: 10),
		]
		XCTAssertEqual(SendHistoryRules.duplicateDate(in: entries, enabledFilterIDs: [a, b], now: now), now.addingTimeInterval(-3600))
	}

	func test_duplicate_ignoresSubsetsOutsideWindowAndUnsent() {
		let a = UUID(), b = UUID()
		let now = Date()
		let entries = [
			(date: now.addingTimeInterval(-60), filterIDs: [a], sentCount: 10),
			(date: now.addingTimeInterval(-25 * 3600), filterIDs: [a, b], sentCount: 10),
			(date: now.addingTimeInterval(-60), filterIDs: [a, b], sentCount: 0),
		]
		XCTAssertNil(SendHistoryRules.duplicateDate(in: entries, enabledFilterIDs: [a, b], now: now))
		XCTAssertNil(SendHistoryRules.duplicateDate(in: entries, enabledFilterIDs: [], now: now))
	}

	func test_grouped_splitsByDayPreservingOrder() {
		var calendar = Calendar(identifier: .gregorian)
		calendar.timeZone = TimeZone(secondsFromGMT: 0)!
		let day1 = Date(timeIntervalSince1970: 1_700_000_000)
		let items = [day1, day1.addingTimeInterval(-60), day1.addingTimeInterval(-86_400 * 2)]
		let groups = SendHistoryRules.grouped(items, date: { $0 }, calendar: calendar)
		XCTAssertEqual(groups.map(\.items.count), [2, 1])
	}

	func test_overflow_returnsOldestBeyondCap() {
		XCTAssertEqual(SendHistoryRules.overflow([1, 2, 3, 4, 5], cap: 3), [4, 5])
		XCTAssertTrue(SendHistoryRules.overflow([Int](), cap: 3).isEmpty)
	}

	func test_survivors() {
		let a = UUID(), b = UUID(), c = UUID()
		let result = SendHistoryRules.survivors(of: [a, b, c], existing: [a, c, UUID()])
		XCTAssertEqual(result.kept, [a, c])
		XCTAssertEqual(result.skipped, 1)
	}
}
