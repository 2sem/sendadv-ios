//
//  SendHistoryComponents.swift
//  App
//

import SwiftUI

extension SendHistoryStatus {
	var titleKey: String {
		switch self {
		case .completed: return "history.status.sent"
		case .partial: return "history.status.partial"
		case .cancelled: return "history.status.cancelled"
		case .failed: return "history.status.failed"
		}
	}

	var symbolName: String {
		switch self {
		case .completed: return "checkmark.circle.fill"
		case .partial: return "exclamationmark.circle.fill"
		case .cancelled: return "xmark.circle.fill"
		case .failed: return "exclamationmark.triangle.fill"
		}
	}

	var tint: Color {
		switch self {
		case .completed: return .green
		case .partial: return .orange
		case .cancelled: return .gray
		case .failed: return .red
		}
	}
}

enum SendHistoryFormat {
	static func relative(_ date: Date, now: Date = Date()) -> String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .full
		return formatter.localizedString(for: date, relativeTo: now)
	}

	static func recipients(_ count: Int) -> String {
		String(localized: "\(count) recipients", table: "Plural")
	}

	static func time(_ date: Date) -> String {
		date.formatted(date: .omitted, time: .shortened)
	}

	static func full(_ date: Date) -> String {
		date.formatted(date: .long, time: .shortened)
	}

	static func dayTitle(_ day: Date, calendar: Calendar = .current) -> String {
		if calendar.isDateInToday(day) { return "history.today".localized() }
		if calendar.isDateInYesterday(day) { return "history.yesterday".localized() }
		return day.formatted(.dateTime.year().month().day().weekday(.abbreviated))
	}

	static func filterNames(_ names: [String]) -> String {
		names.map { $0.isEmpty ? "New Rule".localized() : $0 }.joined(separator: " · ")
	}
}

struct SendHistoryStatusPill: View {
	let status: SendHistoryStatus
	var isLarge = false

	var body: some View {
		Label(status.titleKey.localized(), systemImage: status.symbolName)
			.font(isLarge ? .subheadline.weight(.semibold) : .caption.weight(.medium))
			.foregroundStyle(status.tint)
			.padding(.horizontal, isLarge ? 14 : 10)
			.padding(.vertical, isLarge ? 7 : 4)
			.background(status.tint.opacity(0.15), in: .capsule)
			.accessibilityElement(children: .ignore)
			.accessibilityLabel(status.titleKey.localized())
	}
}

struct LastSentChip: View {
	let date: Date
	let recipientCount: Int
	let action: () -> Void

	private var label: Text {
		Text(String(format: "history.last.sent".localized(), SendHistoryFormat.relative(date)))
			+ Text(" · ")
			+ Text("\(recipientCount) recipients", tableName: "Plural")
	}

	var body: some View {
		Button(action: action) {
			HStack(spacing: 8) {
				Image(systemName: "clock.arrow.circlepath")
				label
					.lineLimit(2)
					.multilineTextAlignment(.leading)
				Image(systemName: "chevron.right")
					.font(.caption2.weight(.bold))
			}
			.font(.footnote.weight(.semibold))
			.foregroundStyle(Color.softAccent)
			.padding(.horizontal, 14)
			.padding(.vertical, 8)
			.frame(minHeight: 44)
			.background(Color.softAccent.opacity(0.12), in: .capsule)
			.contentShape(Capsule())
		}
		.buttonStyle(.plain)
		.frame(maxWidth: .infinity, alignment: .leading)
		.accessibilityLabel(String(
			format: "history.chip.a11y".localized(),
			SendHistoryFormat.relative(date),
			SendHistoryFormat.recipients(recipientCount)
		))
		.accessibilityAddTraits(.isButton)
	}
}

/// Orange inline row shown in the send confirmation sheet.
struct SendWarningRow: View {
	let text: String
	var symbolName = "exclamationmark.triangle"

	var body: some View {
		HStack(alignment: .firstTextBaseline, spacing: 10) {
			Image(systemName: symbolName)
				.accessibilityHidden(true)
			Text(text)
				.fixedSize(horizontal: false, vertical: true)
		}
		.font(.system(size: 13, weight: .semibold, design: .rounded))
		.foregroundStyle(Color.softWarning)
		.padding(.horizontal, 14)
		.padding(.vertical, 10)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color.softWarning.opacity(0.14), in: .rect(cornerRadius: 16, style: .continuous))
		.accessibilityElement(children: .combine)
	}
}
