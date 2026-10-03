//
//  TemplateEditorSheet.swift
//  App
//

import SwiftUI
import SwiftData

struct TemplateEditorSheet: View {
	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss

	/// nil creates a new template.
	let template: MessageTemplate?
	let onSaved: (MessageTemplate) -> Void

	private enum Field: Hashable {
		case title
		case body
	}

	@State private var title: String
	@State private var messageBody: String
	@State private var titleTouched = false
	@State private var bodyTouched = false
	@State private var showingDiscardDialog = false
	@State private var saveFailed = false
	@State private var didAnnounceLMS = false
	@FocusState private var focusedField: Field?
	@ScaledMetric(relativeTo: .body) private var bodyMinHeight: CGFloat = 160

	init(template: MessageTemplate?, onSaved: @escaping (MessageTemplate) -> Void = { _ in }) {
		self.template = template
		self.onSaved = onSaved
		_title = State(initialValue: template?.title ?? "")
		_messageBody = State(initialValue: template?.body ?? "")
	}

	private var isDirty: Bool {
		title != (template?.title ?? "") || messageBody != (template?.body ?? "")
	}

	private var canSave: Bool {
		MessageTemplateRules.isValid(title: title, body: messageBody)
	}

	var body: some View {
		NavigationStack {
			Form {
				titleSection
				bodySection
				if saveFailed {
					Section {
						Label("template.save.failed".localized(), systemImage: "exclamationmark.triangle.fill")
							.font(.system(.footnote, design: .rounded))
							.foregroundStyle(Color.softSecondaryText)
							.listRowBackground(Color.softSurface)
					}
				}
			}
			.scrollContentBackground(.hidden)
			.background(Color.softBackground)
			.scrollDismissesKeyboard(.interactively)
			.onTapGesture { focusedField = nil }
			.navigationTitle((template == nil ? "template.editor.new.title" : "template.editor.edit.title").localized())
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel".localized()) {
						requestDismiss()
					}
				}
				ToolbarItem(placement: .confirmationAction) {
					Button {
						save()
					} label: {
						Text("Save".localized()).bold()
					}
					.disabled(!canSave)
				}
			}
			.confirmationDialog(
				"template.discard.title".localized(),
				isPresented: $showingDiscardDialog,
				titleVisibility: .visible
			) {
				Button("template.discard.confirm".localized(), role: .destructive) {
					dismiss()
				}
				Button("template.discard.keep".localized(), role: .cancel) { }
			}
		}
		.presentationDetents([.large])
		.presentationDragIndicator(.visible)
		.interactiveDismissDisabled(isDirty)
		.task {
			focusedField = .title
		}
		.onChange(of: focusedField) { oldValue, _ in
			if oldValue == .title { titleTouched = true }
			if oldValue == .body { bodyTouched = true }
		}
	}

	// MARK: - Sections

	private var titleSection: some View {
		Section {
			TextField("template.field.title.placeholder".localized(), text: $title)
				.font(.system(.body, design: .rounded))
				.focused($focusedField, equals: .title)
				.submitLabel(.next)
				.onSubmit { focusedField = .body }
				.onChange(of: title) { _, newValue in
					let clamped = MessageTemplateRules.clamped(newValue, limit: MessageTemplateRules.titleLimit)
					if clamped != newValue { title = clamped }
				}
				.listRowBackground(Color.softSurface)
		} header: {
			Text("template.field.title".localized())
		} footer: {
			VStack(alignment: .leading, spacing: 4) {
				if title.count >= MessageTemplateRules.titleCounterThreshold {
					counterText(title.count, MessageTemplateRules.titleLimit)
				}
				if titleTouched && MessageTemplateRules.trimmed(title).isEmpty {
					errorCaption("template.error.title.empty")
				}
			}
		}
	}

	private var bodySection: some View {
		Section {
			TextEditor(text: $messageBody)
				.font(.system(.body, design: .rounded))
				.scrollContentBackground(.hidden)
				.focused($focusedField, equals: .body)
				.frame(minHeight: bodyMinHeight)
				.overlay(alignment: .topLeading) {
					if messageBody.isEmpty {
						Text("template.field.body.placeholder".localized())
							.font(.system(.body, design: .rounded))
							.foregroundStyle(Color.softSecondaryText)
							.padding(.top, 8)
							.padding(.leading, 5)
							.allowsHitTesting(false)
							.accessibilityHidden(true)
					}
				}
				.onChange(of: messageBody) { _, newValue in
					let clamped = MessageTemplateRules.clamped(newValue, limit: MessageTemplateRules.bodyLimit)
					if clamped != newValue { messageBody = clamped }
					announceLMSIfNeeded(clamped)
				}
				.listRowBackground(Color.softSurface)
		} header: {
			Text("template.field.body".localized())
		} footer: {
			VStack(alignment: .leading, spacing: 4) {
				HStack(alignment: .firstTextBaseline) {
					counterText(messageBody.count, MessageTemplateRules.bodyLimit)
					Spacer()
					if MessageTemplateRules.mayBeSentAsLMS(messageBody) {
						Label {
							Text("template.length.lms".localized())
								.foregroundStyle(Color.softSecondaryText)
						} icon: {
							Image(systemName: "info.circle")
								.foregroundStyle(Color.softWarning)
						}
						.font(.system(.footnote, design: .rounded))
					}
				}
				if bodyTouched && MessageTemplateRules.trimmed(messageBody).isEmpty {
					errorCaption("template.error.body.empty")
				}
			}
		}
	}

	private func counterText(_ count: Int, _ limit: Int) -> some View {
		Text(String(format: "template.length.counter".localized(), count, limit))
			.font(.system(.footnote, design: .rounded))
			.foregroundStyle(Color.softSecondaryText)
			.monospacedDigit()
	}

	private func errorCaption(_ key: String) -> some View {
		Label {
			Text(key.localized())
				.foregroundStyle(Color.softSecondaryText)
		} icon: {
			Image(systemName: "exclamationmark.circle.fill")
				.foregroundStyle(Color.softWarning)
		}
		.font(.system(.caption, design: .rounded))
	}

	// MARK: - Actions

	private func announceLMSIfNeeded(_ text: String) {
		if MessageTemplateRules.mayBeSentAsLMS(text) {
			guard !didAnnounceLMS else { return }
			didAnnounceLMS = true
			UIAccessibility.post(notification: .announcement, argument: "template.length.lms".localized())
		} else {
			didAnnounceLMS = false
		}
	}

	private func requestDismiss() {
		if isDirty {
			showingDiscardDialog = true
		} else {
			dismiss()
		}
	}

	private func save() {
		guard canSave else { return }
		let trimmedTitle = MessageTemplateRules.trimmed(title)
		let trimmedBody = MessageTemplateRules.trimmed(messageBody)
		let target: MessageTemplate
		let isNew: Bool

		if let template {
			target = template
			isNew = false
		} else {
			target = MessageTemplate(title: trimmedTitle, body: trimmedBody)
			isNew = true
		}

		let previousTitle = target.title
		let previousBody = target.body
		target.title = trimmedTitle
		target.body = trimmedBody
		if isNew { modelContext.insert(target) }

		do {
			try modelContext.save()
			onSaved(target)
			dismiss()
		} catch {
			if isNew {
				modelContext.delete(target)
			} else {
				target.title = previousTitle
				target.body = previousBody
			}
			saveFailed = true
		}
	}
}
