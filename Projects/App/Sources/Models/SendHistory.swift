//
//  SendHistory.swift
//  App
//

import Foundation
import SwiftData

enum SendHistoryStatus: String, Sendable {
	case completed
	case partial
	case cancelled
	case failed
}

/// A record of one send attempt. Never stores phone numbers or individual names.
@Model
final class SendHistory {
	var id: UUID = UUID()
	var date: Date = Date()
	/// Names of the contact filters used, index-aligned with `filterIDs`.
	var filterNames: [String] = []
	var filterIDs: [UUID] = []
	var totalCount: Int = 0
	var sentCount: Int = 0
	var statusRaw: String = SendHistoryStatus.cancelled.rawValue
	var body: String = ""

	var status: SendHistoryStatus {
		get { SendHistoryStatus(rawValue: statusRaw) ?? .cancelled }
		set { statusRaw = newValue.rawValue }
	}

	init(
		date: Date = Date(),
		filterNames: [String],
		filterIDs: [UUID],
		totalCount: Int,
		sentCount: Int = 0,
		status: SendHistoryStatus = .cancelled,
		body: String
	) {
		self.id = UUID()
		self.date = date
		self.filterNames = filterNames
		self.filterIDs = filterIDs
		self.totalCount = totalCount
		self.sentCount = sentCount
		self.statusRaw = status.rawValue
		self.body = body
	}
}

/// Pure rules for send history: status computation, duplicate detection, grouping, pruning.
enum SendHistoryRules {
	static let maxRecords = 500
	static let duplicateWindow: TimeInterval = 24 * 60 * 60

	/// Result of one composer presentation.
	enum BatchOutcome: Sendable {
		case sent
		case cancelled
		case failed
	}

	/// Sent count after a batch result. Only a sent batch adds to the count; never exceeds the total.
	static func updatedSentCount(current: Int, batchCount: Int, totalCount: Int, outcome: BatchOutcome) -> Int {
		guard outcome == .sent else { return current }
		return min(current + max(batchCount, 0), max(totalCount, 0))
	}

	static func status(sentCount: Int, totalCount: Int, outcome: BatchOutcome) -> SendHistoryStatus {
		switch outcome {
		case .sent:
			return totalCount > 0 && sentCount >= totalCount ? .completed : (sentCount > 0 ? .partial : .cancelled)
		case .cancelled:
			return sentCount > 0 ? .partial : .cancelled
		case .failed:
			return sentCount > 0 ? .partial : .failed
		}
	}

	/// True when the send session is over after this outcome.
	static func isSessionFinished(sentCount: Int, totalCount: Int, outcome: BatchOutcome) -> Bool {
		outcome != .sent || sentCount >= totalCount
	}

	/// Date of the most recent record that actually sent something to exactly this set of filters within the window.
	static func duplicateDate(
		in entries: [(date: Date, filterIDs: [UUID], sentCount: Int)],
		enabledFilterIDs: Set<UUID>,
		now: Date = Date(),
		window: TimeInterval = duplicateWindow
	) -> Date? {
		guard !enabledFilterIDs.isEmpty else { return nil }
		return entries
			.filter { entry in
				entry.sentCount > 0
					&& Set(entry.filterIDs) == enabledFilterIDs
					&& entry.date <= now
					&& now.timeIntervalSince(entry.date) <= window
			}
			.map(\.date)
			.max()
	}

	struct DayGroup<Item> {
		let day: Date
		let items: [Item]
	}

	/// Groups items by calendar day, preserving the input order (expected newest first).
	static func grouped<Item>(_ items: [Item], date: (Item) -> Date, calendar: Calendar = .current) -> [DayGroup<Item>] {
		var groups: [DayGroup<Item>] = []
		var currentDay: Date?
		var bucket: [Item] = []
		for item in items {
			let day = calendar.startOfDay(for: date(item))
			if let currentDay, currentDay == day {
				bucket.append(item)
			} else {
				if let currentDay { groups.append(DayGroup(day: currentDay, items: bucket)) }
				currentDay = day
				bucket = [item]
			}
		}
		if let currentDay { groups.append(DayGroup(day: currentDay, items: bucket)) }
		return groups
	}

	/// Items beyond the cap. Input must be sorted newest first.
	static func overflow<Item>(_ sortedNewestFirst: [Item], cap: Int = maxRecords) -> [Item] {
		guard sortedNewestFirst.count > cap else { return [] }
		return Array(sortedNewestFirst[cap...])
	}

	/// Filter IDs that still exist, and how many were skipped.
	static func survivors(of recordIDs: [UUID], existing: Set<UUID>) -> (kept: Set<UUID>, skipped: Int) {
		let unique = Set(recordIDs)
		let kept = unique.intersection(existing)
		return (kept, unique.count - kept.count)
	}
}
