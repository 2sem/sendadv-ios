//
//  MessageTemplatesScreen.swift
//  App
//

import SwiftUI
import SwiftData

struct MessageTemplatesScreen: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Query(sort: \MessageTemplate.createdAt, order: .reverse) private var templates: [MessageTemplate]
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	/// When true the screen is presented as a sheet and shows a leading Done button.
	var showsDoneButton = false
	/// Opens the new-template editor as soon as the screen appears.
	var startsWithNewEditor = false

	private enum Editor: Identifiable {
		case new
		case edit(MessageTemplate)

		var id: String {
			switch self {
			case .new: return "new"
			case .edit(let template): return "edit-\(template.persistentModelID.hashValue)"
			}
		}
	}

	@State private var editor: Editor?
	@State private var templatePendingDeletion: MessageTemplate?
	@State private var showingDeleteConfirmation = false
	@State private var saveFeedbackCount = 0
	@State private var deleteFeedbackCount = 0
	@State private var didAutoOpen = false

	var body: some View {
		Group {
			if templates.isEmpty {
				emptyState
			} else {
				templateList
			}
		}
		.background(Color.softBackground)
		.navigationTitle("template.screen.title".localized())
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			if showsDoneButton {
				ToolbarItem(placement: .topBarLeading) {
					Button("Done".localized()) { dismiss() }
				}
			}
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					editor = .new
				} label: {
					Image(systemName: "plus")
				}
				.tint(Color.softAccent)
				.accessibilityLabel("template.add".localized())
			}
		}
		.sheet(item: $editor) { editor in
			switch editor {
			case .new:
				TemplateEditorSheet(template: nil) { _ in saveFeedbackCount += 1 }
			case .edit(let template):
				TemplateEditorSheet(template: template) { _ in saveFeedbackCount += 1 }
			}
		}
		.confirmationDialog(
			"template.delete.title".localized(),
			isPresented: $showingDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("template.delete.confirm".localized(), role: .destructive) {
				if let template = templatePendingDeletion {
					delete(template)
				}
				templatePendingDeletion = nil
			}
			Button("Cancel".localized(), role: .cancel) {
				templatePendingDeletion = nil
			}
		}
		.sensoryFeedback(.success, trigger: saveFeedbackCount)
		.sensoryFeedback(.warning, trigger: deleteFeedbackCount)
		.onAppear {
			guard startsWithNewEditor, !didAutoOpen else { return }
			didAutoOpen = true
			editor = .new
		}
	}

	// MARK: - Subviews

	private var emptyState: some View {
		ContentUnavailableView {
			Label("template.empty.title".localized(), systemImage: "text.bubble")
		} description: {
			Text("template.empty.message".localized())
		} actions: {
			Button {
				editor = .new
			} label: {
				Text("template.empty.action".localized())
			}
			.buttonStyle(SoftFriendlyPrimaryButtonStyle())
			.padding(.horizontal, 36)
		}
	}

	private var templateList: some View {
		List {
			ForEach(templates) { template in
				row(for: template)
					.listRowBackground(Color.softSurface)
					.listRowSeparatorTint(Color.softDivider)
			}
		}
		.listStyle(.insetGrouped)
		.scrollContentBackground(.hidden)
		.background(Color.softBackground)
	}

	private func row(for template: MessageTemplate) -> some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(template.title)
				.font(.system(.headline, design: .rounded))
				.foregroundStyle(Color.softPrimaryText)
				.lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : 1)
			Text(template.body)
				.font(.system(.subheadline, design: .rounded))
				.foregroundStyle(Color.softSecondaryText)
				.lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
		}
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(.vertical, 8)
		.contentShape(Rectangle())
		.onTapGesture {
			editor = .edit(template)
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			Button(role: .destructive) {
				requestDelete(template)
			} label: {
				Label("template.delete".localized(), systemImage: "trash")
			}
			Button {
				editor = .edit(template)
			} label: {
				Label("template.edit".localized(), systemImage: "pencil")
			}
			.tint(Color.softAccent)
		}
		.contextMenu {
			Button {
				editor = .edit(template)
			} label: {
				Label("template.edit".localized(), systemImage: "pencil")
			}
			Button(role: .destructive) {
				requestDelete(template)
			} label: {
				Label("template.delete".localized(), systemImage: "trash")
			}
		}
		.accessibilityElement(children: .ignore)
		.accessibilityLabel("\(template.title), \(template.body)")
		.accessibilityAddTraits(.isButton)
		.accessibilityAction(named: Text("template.edit".localized())) {
			editor = .edit(template)
		}
		.accessibilityAction(named: Text("template.delete".localized())) {
			requestDelete(template)
		}
	}

	// MARK: - Actions

	private func requestDelete(_ template: MessageTemplate) {
		templatePendingDeletion = template
		showingDeleteConfirmation = true
	}

	private func delete(_ template: MessageTemplate) {
		modelContext.delete(template)
		try? modelContext.save()
		deleteFeedbackCount += 1
	}
}
