//
//  RecipientFilterListScreen.swift
//  App
//
//  Created by 영준 이 on 8/6/25.
//

import SwiftUI
import SwiftData
import Contacts

struct RuleDetailScreen: View {
	@Environment(\.modelContext) private var modelContext
    @Environment(\.undoManager) private var undoManager
	@Environment(\.dismiss) private var dismiss
	
	@State private var viewModel: RuleDetailScreenModel
	@State private var selectedFilter: RecipientsFilter?
	@State private var showDiscardConfirmation: Bool = false
	@FocusState private var isTitleFocused: Bool
	
	init(rule: RecipientsRule?) {
		_viewModel = State(initialValue: RuleDetailScreenModel(rule: rule))
	}
	
	var body: some View {
		ZStack {
			Color.softBackground
				.ignoresSafeArea()

			VStack(spacing: 0) {
				ScrollView {
					VStack(alignment: .leading, spacing: 0) {
						RuleNameCard(title: $viewModel.title, isFocused: $isTitleFocused)

						Text("rule.detail.match.section".localized())
							.font(.system(size: 13, weight: .semibold, design: .rounded))
							.foregroundStyle(Color.softSecondaryText)
							.padding(.top, 22)
							.padding(.horizontal, 6)
							.padding(.bottom, 14)

						VStack(spacing: 12) {
							RuleFilterCategoryCard(
								title: "Job".localized(),
								subtitle: detailSubtitle(viewModel.getJobFilterText()),
								style: .job
							) {
								selectedFilter = viewModel.getOrCreateFilter(for: "job")
							}

							RuleFilterCategoryCard(
								title: "Department".localized(),
								subtitle: detailSubtitle(viewModel.getDepartmentFilterText()),
								style: .department
							) {
								selectedFilter = viewModel.getOrCreateFilter(for: "dept")
							}

							RuleFilterCategoryCard(
								title: "Organization".localized(),
								subtitle: detailSubtitle(viewModel.getOrganizationFilterText()),
								style: .organization(isAny: viewModel.getOrganizationFilterText() == "All".localized())
							) {
								selectedFilter = viewModel.getOrCreateFilter(for: "org")
							}
						}
					}
					.padding(.horizontal, 22)
					.padding(.top, 6)
					.padding(.bottom, 28)
				}
				.scrollIndicators(.hidden)

				switch viewModel.recipientCountState {
				case .available(let count) where count > 0:
					RecipientCountBar(count: count)
				case .permissionDenied:
					RecipientCountPermissionDeniedBar()
				default:
					EmptyView()
				}
			}
		}
		.onAppear {
			viewModel.loadRecipientCountIfNeeded()
		}
		.onDisappear {
			viewModel.cancelRecipientCountWork()
		}
		.onChange(of: selectedFilter) { oldValue, newValue in
			if oldValue != nil && newValue == nil {
				viewModel.scheduleRecipientCountRecompute()
			}
		}
		.navigationTitle("rule.detail.title.new".localized())
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button(action: handleBack) {
					Image(systemName: "chevron.left")
						.font(.system(size: 16, weight: .bold))
						.foregroundStyle(Color.softPrimaryText)
				}
				.accessibilityLabel("Back".localized())
			}

			ToolbarItem(placement: .topBarTrailing) {
				Button("Save".localized(), action: saveAndDismiss)
					.font(.system(size: 15.5, weight: .bold, design: .rounded))
					.foregroundStyle(Color.softAccent)
			}
		}
		.navigationDestination(item: $selectedFilter) { filter in
//			let title: String
//			switch filter.target {
//			case "job": title = "직책 필터"
//			case "dept": title = "부서 필터"
//			case "org": title = "조직 필터"
//			default: title = "필터"
//			}

            RuleFilterScreen(filter: filter)
        }
		.confirmationDialog(
			"unsaved.changes.title".localized(),
			isPresented: $showDiscardConfirmation,
			titleVisibility: .visible
		) {
			Button("Save".localized()) {
				viewModel.save(using: modelContext);
				dismiss();
			}
			Button("unsaved.changes.discard".localized(), role: .destructive) {
				if let undoManager {
					viewModel.rollback(withUndoManager: undoManager);
				}
				dismiss();
			}
			Button("Cancel".localized(), role: .cancel) {}
		}
	}

	private func handleBack() {
		if viewModel.hasChanges {
			showDiscardConfirmation = true
		} else {
			if let undoManager {
				viewModel.rollback(withUndoManager: undoManager)
			}
			dismiss()
		}
	}

	private func saveAndDismiss() {
		viewModel.save(using: modelContext)
		dismiss()
	}

	private func detailSubtitle(_ value: String) -> String {
		value == "All".localized() ? "Anyone".localized() : value
	}
}

/// Pinned bar showing the live count of sendable phone numbers (deduped mobiles, not raw
/// contacts) matched by the rule's current filter conditions. Sits below the scroll content,
/// above the safe area. Deliberately unlike `RuleFilterCategoryCard` - no corner radius, no
/// shadow, no chevron - since it isn't tappable.
private struct RecipientCountBar: View {
	let count: Int

	var body: some View {
		HStack {
			Text("rule.detail.recipient.count.label".localized())
				.font(.system(size: 12.5, weight: .semibold, design: .rounded))
				.foregroundStyle(Color.softSecondaryText)

			Spacer()

			// Plural: SwiftUI derives the LocalizedStringKey "%lld recipients" from this Int
			// interpolation and resolves it against `Localizable.stringsdict` (en one/other,
			// ko other-only) - no `.localized()` or manual `String(format:)` involved.
			Text("\(count) recipients")
				.font(.system(size: 22, weight: .bold, design: .rounded))
				.foregroundStyle(Color.softAccent)
				.contentTransition(.numericText())
		}
		.padding(.horizontal, 22)
		.padding(.vertical, 14)
		.background(Color.softSurface)
		.overlay(alignment: .top) {
			Divider()
				.background(Color.softDivider)
		}
		.accessibilityElement(children: .combine)
	}
}

/// Pinned bar shown when contacts access is denied or restricted. Same placement, `Color
/// .softSurface` background and hairline top divider as `RecipientCountBar` - but unlike that
/// bar, this one is deliberately tappable: it opens the app's own Settings page so the user can
/// grant access. The trailing text is styled with `Color.softAccent` so it reads as a button
/// even though the whole row shares one flat, cardless treatment.
private struct RecipientCountPermissionDeniedBar: View {
	var body: some View {
		Button(action: openSettings) {
			HStack {
				Text("rule.detail.recipient.count.permission_denied")
					.font(.system(size: 12.5, weight: .semibold, design: .rounded))
					.foregroundStyle(Color.softSecondaryText)

				Spacer()

				Text("rule.detail.recipient.count.open_settings")
					.font(.system(size: 13, weight: .bold, design: .rounded))
					.foregroundStyle(Color.softAccent)
			}
			.padding(.horizontal, 22)
			.padding(.vertical, 14)
			.background(Color.softSurface)
			.overlay(alignment: .top) {
				Divider()
					.background(Color.softDivider)
			}
			.contentShape(Rectangle())
		}
		.buttonStyle(.plain)
		.accessibilityElement(children: .combine)
	}

	private func openSettings() {
		guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
		UIApplication.shared.open(url)
	}
}

private struct RuleNameCard: View {
	@Binding var title: String
	let isFocused: FocusState<Bool>.Binding

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("rule.detail.name.label".localized())
				.font(.system(size: 12.5, weight: .semibold, design: .rounded))
				.foregroundStyle(Color.softSecondaryText)

			TextField("Enter rule title".localized(), text: $title)
				.font(.system(size: 22, weight: .bold, design: .rounded))
				.foregroundStyle(Color.softPrimaryText)
				.tint(.softAccent)
				.focused(isFocused)
				.textInputAutocapitalization(.sentences)
				.autocorrectionDisabled()
		}
		.padding(.horizontal, 20)
		.padding(.vertical, 16)
		.background(Color.softSurface, in: .rect(cornerRadius: 20, style: .continuous))
		.shadow(color: Color.softAccent.opacity(0.07), radius: 18, x: 0, y: 6)
	}
}

private struct RuleFilterCategoryCard: View {
	let title: String
	let subtitle: String
	let style: RuleDetailCategoryStyle
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack(spacing: 14) {
				ZStack {
					RoundedRectangle(cornerRadius: 15, style: .continuous)
						.fill(style.background)

					Image(systemName: style.symbolName)
						.font(.system(size: 22, weight: .semibold))
						.foregroundStyle(style.foreground)
				}
				.frame(width: 44, height: 44)

				VStack(alignment: .leading, spacing: 3) {
					Text(title)
						.font(.system(size: 16, weight: .bold, design: .rounded))
						.foregroundStyle(Color.softPrimaryText)

					Text(subtitle)
						.font(.system(size: 12.5, weight: style.isNeutral ? .regular : .semibold, design: .rounded))
						.foregroundStyle(style.subtitleColor)
						.lineLimit(1)
				}

				Spacer()

				Image(systemName: "chevron.right")
					.font(.system(size: 15, weight: .bold))
					.foregroundStyle(Color.dynamic(light: "#CDC8D8", dark: "#6B6478"))
			}
			.padding(.horizontal, 18)
			.padding(.vertical, 14)
			.background(Color.softSurface, in: .rect(cornerRadius: 20, style: .continuous))
			.shadow(color: Color.softAccent.opacity(0.07), radius: 18, x: 0, y: 6)
		}
		.buttonStyle(.plain)
		.accessibilityElement(children: .combine)
	}
}

private struct RuleDetailCategoryStyle {
	let symbolName: String
	let background: Color
	let foreground: Color
	let subtitleColor: Color
	let isNeutral: Bool

	static let job = RuleDetailCategoryStyle(
		symbolName: "briefcase",
		background: .softJobTint,
		foreground: .softAccent,
		subtitleColor: .softAccent,
		isNeutral: false
	)

	static let department = RuleDetailCategoryStyle(
		symbolName: "building.2",
		background: .softDepartmentTint,
		foreground: .dynamic(light: "#E8895B", dark: "#E8A07B"),
		subtitleColor: .dynamic(light: "#E8895B", dark: "#E8A07B"),
		isNeutral: false
	)

	static func organization(isAny: Bool) -> RuleDetailCategoryStyle {
		RuleDetailCategoryStyle(
			symbolName: "building.2",
			background: isAny ? .dynamic(light: "#F0EEF4", dark: "#302B3A") : .softOrganizationTint,
			foreground: isAny ? .softSecondaryText : .dynamic(light: "#2BA55D", dark: "#5FCB8A"),
			subtitleColor: isAny ? .dynamic(light: "#B3ACC0", dark: "#6B6478") : .dynamic(light: "#2BA55D", dark: "#5FCB8A"),
			isNeutral: isAny
		)
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: RecipientsRule.self, configurations: config)
	
	let rule = RecipientsRule(title: "샘플 규칙", enabled: true, order: 1)
	container.mainContext.insert(rule)
	
	return NavigationStack {
		RuleDetailScreen(rule: rule)
	}
	.modelContainer(container)
}
