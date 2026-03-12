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
	let onToggle: (Bool) -> Void

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
		return "\(keywords[0])".localized() + " and \(keywords.count - 1) others".localized();
	}

	private var filterSummary: String {
		var parts: [String] = [];
		let targets: [(rawValue: String, labelKey: String)] = [
			("job", "Job"),
			("dept", "Department"),
			("org", "Organization"),
		];
		for (rawValue, labelKey) in targets {
			if let value = filterText(for: rawValue) {
				parts.append("\(labelKey.localized()): \(value)");
			}
		}
		if parts.isEmpty {
			return "rule.row.allContacts".localized();
		}
		return parts.joined(separator: "  |  ");
	}

	var body: some View {
		ZStack {
			Color.background

			HStack {
				VStack(alignment: .leading, spacing: 4) {
					if let title = rule.title, !title.isEmpty {
						Text(title)
							.font(.headline)
							.foregroundStyle(Color.title)
					} else {
						Text("수신자 목록 생성 규칙")
							.font(.headline)
							.foregroundStyle(Color.title)
					}

					Text(filterSummary)
						.font(.caption)
						.foregroundStyle(.secondary)
				}

				Spacer()

				Toggle("", isOn: Binding(
					get: { rule.enabled },
					set: { onToggle($0) }
				)).padding(.trailing, 16)
			}
			.padding(.leading, 32)
			.padding(.trailing, 16)
			.padding(.vertical, 12)
		}
	}
}

struct RecipientRuleRowView_Previews: PreviewProvider {
	static var previews: some View {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		let container = try! ModelContainer(for: RecipientsRule.self, configurations: config)

		let rule = RecipientsRule(title: "회사 동료들", enabled: true)
		container.mainContext.insert(rule)

		return RecipientRuleRowView(rule: rule) { isOn in }
			.previewLayout(.sizeThatFits)
			.modelContainer(container)
	}
}
