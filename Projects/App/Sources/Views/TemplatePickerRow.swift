//
//  TemplatePickerRow.swift
//  App
//

import SwiftUI
import SwiftData

/// Template picker shown inside the send confirmation sheet.
/// Selection is held by the parent as a persistent identifier so it survives across batches.
struct TemplatePickerRow: View {
	let templates: [MessageTemplate]
	@Binding var selectedID: PersistentIdentifier?
	let onManage: () -> Void
	let onCreate: () -> Void

	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	private var selectedTemplate: MessageTemplate? {
		guard let selectedID else { return nil }
		return templates.first { $0.persistentModelID == selectedID }
	}

	private var selectedName: String {
		selectedTemplate?.title ?? "template.send.none".localized()
	}

	var body: some View {
		Group {
			if templates.isEmpty {
				createRow
			} else {
				menuRow
			}
		}
		.dynamicTypeSize(...DynamicTypeSize.accessibility2)
	}

	private var createRow: some View {
		Button(action: onCreate) {
			HStack(spacing: 10) {
				Image(systemName: "plus")
					.font(.system(size: 16, weight: .semibold))
				Text("template.send.create".localized())
					.font(.system(size: 17, weight: .semibold, design: .rounded))
				Spacer(minLength: 0)
			}
			.foregroundStyle(Color.softAccent)
			.modifier(PickerContainer())
		}
		.buttonStyle(.plain)
	}

	private var menuRow: some View {
		Menu {
			Picker(selection: $selectedID) {
				Text("template.send.none".localized())
					.tag(PersistentIdentifier?.none)
				ForEach(templates) { template in
					Text(template.title)
						.tag(Optional(template.persistentModelID))
				}
			} label: {
				Text("template.send.row.caption".localized())
			}
			Divider()
			Button(action: onManage) {
				Label("template.send.manage".localized(), systemImage: "gearshape")
			}
		} label: {
			rowLabel
				.modifier(PickerContainer())
		}
		.buttonStyle(.plain)
		.accessibilityElement(children: .ignore)
		.accessibilityLabel(String(format: "template.send.row.a11y.label".localized(), selectedName))
		.accessibilityHint("template.send.row.a11y.hint".localized())
	}

	@ViewBuilder
	private var rowLabel: some View {
		if dynamicTypeSize.isAccessibilitySize {
			VStack(alignment: .leading, spacing: 8) {
				Image(systemName: "text.bubble")
					.font(.system(size: 16))
					.foregroundStyle(Color.softAccent)
				textStack
				Image(systemName: "chevron.up.chevron.down")
					.font(.system(size: 12))
					.foregroundStyle(Color.softSecondaryText)
			}
		} else {
			HStack(spacing: 12) {
				Image(systemName: "text.bubble")
					.font(.system(size: 16))
					.foregroundStyle(Color.softAccent)
				textStack
				Spacer(minLength: 8)
				Image(systemName: "chevron.up.chevron.down")
					.font(.system(size: 12))
					.foregroundStyle(Color.softSecondaryText)
			}
		}
	}

	private var textStack: some View {
		VStack(alignment: .leading, spacing: 2) {
			Text("template.send.row.caption".localized())
				.font(.system(size: 13, weight: .semibold, design: .rounded))
				.foregroundStyle(Color.softSecondaryText)
			Text(selectedName)
				.font(.system(size: 17, weight: .semibold, design: .rounded))
				.foregroundStyle(Color.softPrimaryText)
				.lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
				.truncationMode(.tail)
		}
		.multilineTextAlignment(.leading)
	}
}

private struct PickerContainer: ViewModifier {
	func body(content: Content) -> some View {
		content
			.padding(.horizontal, 16)
			.padding(.vertical, 12)
			.frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
			.background(Color.softSurfaceElevated, in: .rect(cornerRadius: 16, style: .continuous))
			.overlay {
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.stroke(Color.softDivider, lineWidth: 1)
			}
			.contentShape(Rectangle())
	}
}
