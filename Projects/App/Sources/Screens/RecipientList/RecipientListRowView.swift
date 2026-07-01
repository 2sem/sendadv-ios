//
//  RecipientListRowView.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import SwiftData

struct RecipientRuleRowView: View {
	let rule: RecipientsRule
	let isEditing: Bool
	let onToggle: (Bool) -> Void
	let onDelete: () -> Void

	var isTitleEmpty: Bool {
		return rule.title?.isEmpty ?? true;
	}

	private func filterText(for rawTarget: String) -> String? {
		guard let filters = rule.filters else { return nil; }
		let filter = filters.first { $0.target == rawTarget };
		if filter == nil || filter?.all == true { return nil; }
		guard let includes = filter?.includes else { return nil; }
		let keywords = includes.components(separatedBy: ",").filter { !$0.isEmpty };
		guard !keywords.isEmpty else { return nil; }
		if keywords.count == 1 { return keywords[0]; }
		return keywords[0].localized() + String(format: " and %@ others".localized(), "\(keywords.count - 1)");
	}

	private var activeFilters: [(rawValue: String, label: String, value: String)] {
		let targets: [(rawValue: String, labelKey: String)] = [
			("job", "Job"),
			("dept", "Department"),
			("org", "Organization"),
		];

		return targets.compactMap { target in
			guard let value = filterText(for: target.rawValue) else { return nil; }
			return (target.rawValue, target.labelKey.localized(), value);
		}
	}

	private var primaryStyle: RuleCategoryStyle {
		guard let first = activeFilters.first else { return .allContacts }

		switch first.rawValue {
		case "job": return .job
		case "dept": return .department
		case "org": return .organization
		default: return .allContacts
		}
	}

	private var summaryText: String {
		guard !activeFilters.isEmpty else { return "rule.row.allContacts".localized() }
		return activeFilters.map(\.value).joined(separator: " · ")
	}

	var body: some View {
		HStack(alignment: .center, spacing: 18) {
			ZStack {
				RoundedRectangle(cornerRadius: 18, style: .continuous)
					.fill(primaryStyle.background)
				Image(systemName: primaryStyle.symbolName)
					.font(.system(size: 25, weight: .semibold))
					.foregroundStyle(primaryStyle.foreground)
			}
			.frame(width: 58, height: 58)

			VStack(alignment: .leading, spacing: 5) {
				Text(isTitleEmpty ? "New Rule".localized() : (rule.title ?? ""))
					.font(.system(size: 22, weight: .bold, design: .rounded))
					.foregroundStyle(Color.softPrimaryText)
					.lineLimit(1)

				Text(summaryText)
					.font(.system(size: 16, weight: .semibold, design: .rounded))
					.foregroundStyle(Color.softSecondaryText)
					.lineLimit(1)
			}

			Spacer(minLength: 8)

			if isEditing {
				Button(role: .destructive, action: onDelete) {
					Image(systemName: "minus.circle.fill")
						.font(.system(size: 30, weight: .semibold))
						.foregroundStyle(.red)
				}
				.buttonStyle(.plain)
				.accessibilityLabel("Delete".localized())
			} else {
				Toggle("", isOn: Binding(
					get: { rule.enabled },
					set: { onToggle($0) }
				))
				.labelsHidden()
				.tint(.softAccent)
				.scaleEffect(1.12)
			}
		}
		.padding(.leading, 24)
		.padding(.trailing, 20)
		.padding(.vertical, 18)
		.softFriendlyCard()
		.opacity(rule.enabled || isEditing ? 1 : 0.72)
		.accessibilityElement(children: .combine)
	}
}

private struct RuleCategoryStyle {
	let symbolName: String
	let background: Color
	let foreground: Color

	static let job = RuleCategoryStyle(symbolName: "briefcase", background: .softJobTint, foreground: .softAccent)
	static let department = RuleCategoryStyle(symbolName: "building.2", background: .softDepartmentTint, foreground: .dynamic(light: "#F2855F", dark: "#FF9D78"))
	static let organization = RuleCategoryStyle(symbolName: "rectangle.3.group", background: .softOrganizationTint, foreground: .dynamic(light: "#2EAD6B", dark: "#67D89C"))
	static let allContacts = RuleCategoryStyle(symbolName: "person", background: .dynamic(light: "#F4F1F4", dark: "#302B3A"), foreground: .dynamic(light: "#B7AFBE", dark: "#8F879B"))
}

struct RecipientRuleRowView_Previews: PreviewProvider {
	static var previews: some View {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: RecipientsRule.self, configurations: config)

		let rule = RecipientsRule(title: "회사 동료들", enabled: true)
		container.mainContext.insert(rule)

		return RecipientRuleRowView(rule: rule, isEditing: false, onToggle: { isOn in }, onDelete: {})
			.previewLayout(.sizeThatFits)
			.modelContainer(container)
	}
}
