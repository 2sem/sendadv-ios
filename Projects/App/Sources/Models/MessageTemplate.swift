//
//  MessageTemplate.swift
//  App
//

import Foundation
import SwiftData

@Model
final class MessageTemplate: Identifiable {
	var id: PersistentIdentifier { persistentModelID }
	var title: String = ""
	var body: String = ""
	var createdAt: Date = Date()

	init(title: String, body: String, createdAt: Date = Date()) {
		self.title = title
		self.body = body
		self.createdAt = createdAt
	}
}

/// Pure validation and length rules for message templates.
enum MessageTemplateRules {
	static let titleLimit = 30
	static let bodyLimit = 500
	/// Estimated byte length above which a message may be sent as LMS.
	static let lmsByteThreshold = 90
	/// Title length from which the counter becomes visible.
	static let titleCounterThreshold = 24

	static func clamped(_ text: String, limit: Int) -> String {
		text.count > limit ? String(text.prefix(limit)) : text
	}

	static func trimmed(_ text: String) -> String {
		text.trimmingCharacters(in: .whitespacesAndNewlines)
	}

	static func isValid(title: String, body: String) -> Bool {
		!trimmed(title).isEmpty && !trimmed(body).isEmpty
	}

	/// Byte estimate: 2 bytes per non-ASCII character, 1 per ASCII character.
	static func estimatedBytes(_ text: String) -> Int {
		text.reduce(0) { $0 + ($1.isASCII ? 1 : 2) }
	}

	static func mayBeSentAsLMS(_ text: String) -> Bool {
		estimatedBytes(text) > lmsByteThreshold
	}
}
