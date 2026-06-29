//
//  RuleFilterScreen.swift
//  App
//
//  Created by sendadv-ios on 2025/08/12.//

import SwiftUI
import SwiftData

struct RuleFilterScreen: View {
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	@State private var viewModel: RuleFilterScreenModel
	@FocusState private var isSearchFocused: Bool

	init(filter: RecipientsFilter) {
		_viewModel = State(initialValue: RuleFilterScreenModel(filter: filter))
	}

	var body: some View {
		let style = RuleFilterCategoryStyle(target: viewModel.target)

		ZStack {
			Color.softBackground
				.ignoresSafeArea()

			VStack(spacing: 0) {
				RuleFilterTopBar(
					title: viewModel.title,
					style: style,
					onBack: { dismiss() },
					onDone: saveAndDismiss
				)
				.padding(.horizontal, 22)
				.padding(.top, 0)
				.padding(.bottom, 10)

				ScrollView {
					VStack(alignment: .leading, spacing: 0) {
						Text(helperText(for: viewModel.target))
							.font(.system(size: 13, weight: .regular, design: .rounded))
							.foregroundStyle(Color.softSecondaryText)
							.padding(.horizontal, 2)
							.padding(.bottom, 12)

						RuleFilterSearchField(
							text: $viewModel.searchText,
							placeholder: searchPlaceholder(for: viewModel.target),
							isFocused: $isSearchFocused
						)

						RuleFilterSelectAllCard(
							title: selectAllTitle(for: viewModel.target),
							subtitle: selectAllSubtitle(for: viewModel.target),
							isOn: Binding(
								get: { viewModel.selectAll },
								set: { viewModel.toggleSelectAll($0) }
							)
						)
						.padding(.top, 14)

						HStack {
							Text(itemCountText(for: viewModel.target, count: viewModel.availableItems.count))
								.font(.system(size: 12, weight: .semibold, design: .rounded))
								.textCase(.uppercase)
								.tracking(0.4)
								.foregroundStyle(Color.softSecondaryText)

							Spacer()

							Text(String(format: "rule.filter.selected.count".localized(), viewModel.selectedCount))
								.font(.system(size: 12.5, weight: .bold, design: .rounded))
								.foregroundStyle(style.accent)
						}
						.padding(.horizontal, 4)
						.padding(.top, 20)
						.padding(.bottom, 10)

						RuleFilterItemsPanel(
							items: viewModel.filteredItems,
							selectedItems: viewModel.selectedItems,
							style: style,
							onToggle: { item in viewModel.toggleItem(item) }
						)
					}
					.padding(.horizontal, 22)
					.padding(.top, 6)
					.padding(.bottom, 28)
				}
				.scrollIndicators(.hidden)
			}
		}
		.navigationTitle("")
		.navigationBarTitleDisplayMode(.inline)
		.navigationBarBackButtonHidden(true)
		.toolbarVisibility(.hidden, for: .navigationBar)
		.onAppear {
			viewModel.loadItems()
		}
	}

	private func saveAndDismiss() {
		viewModel.save(context: modelContext)
		dismiss()
	}

	private func helperText(for target: FilterTarget?) -> String {
		switch target {
		case .job:
			return "rule.filter.helper.job".localized()
		case .department:
			return "rule.filter.helper.department".localized()
		case .organization:
			return "rule.filter.helper.organization".localized()
		case .none:
			return "rule.filter.helper.default".localized()
		}
	}

	private func searchPlaceholder(for target: FilterTarget?) -> String {
		switch target {
		case .job:
			return "rule.filter.search.job".localized()
		case .department:
			return "rule.filter.search.department".localized()
		case .organization:
			return "rule.filter.search.organization".localized()
		case .none:
			return "rule.filter.search.default".localized()
		}
	}

	private func selectAllTitle(for target: FilterTarget?) -> String {
		switch target {
		case .job:
			return "rule.filter.selectAll.job".localized()
		case .department:
			return "rule.filter.selectAll.department".localized()
		case .organization:
			return "rule.filter.selectAll.organization".localized()
		case .none:
			return "Select All".localized()
		}
	}

	private func selectAllSubtitle(for target: FilterTarget?) -> String {
		switch target {
		case .job:
			return "rule.filter.selectAll.job.subtitle".localized()
		case .department:
			return "rule.filter.selectAll.department.subtitle".localized()
		case .organization:
			return "rule.filter.selectAll.organization.subtitle".localized()
		case .none:
			return "rule.filter.selectAll.default.subtitle".localized()
		}
	}

	private func itemCountText(for target: FilterTarget?, count: Int) -> String {
		switch target {
		case .job:
			return String(format: "rule.filter.count.job".localized(), count)
		case .department:
			return String(format: "rule.filter.count.department".localized(), count)
		case .organization:
			return String(format: "rule.filter.count.organization".localized(), count)
		case .none:
			return String(format: "rule.filter.count.default".localized(), count)
		}
	}
}

private struct RuleFilterTopBar: View {
	let title: String
	let style: RuleFilterCategoryStyle
	let onBack: () -> Void
	let onDone: () -> Void

	var body: some View {
		ZStack {
			HStack(spacing: 8) {
				ZStack {
					RoundedRectangle(cornerRadius: 7, style: .continuous)
						.fill(style.iconBackground)

					Image(systemName: style.symbolName)
						.font(.system(size: 13, weight: .semibold))
						.foregroundStyle(style.accent)
				}
				.frame(width: 22, height: 22)

				Text(title)
					.font(.system(size: 16, weight: .bold, design: .rounded))
					.foregroundStyle(Color.softPrimaryText)
			}

			HStack {
				Button(action: onBack) {
					Image(systemName: "chevron.left")
						.font(.system(size: 16, weight: .bold))
						.foregroundStyle(Color.softPrimaryText)
						.frame(width: 36, height: 36)
						.background(Color.softSurface, in: Circle())
						.shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
				}
				.accessibilityLabel("Back".localized())

				Spacer()

				Button("Done".localized(), action: onDone)
					.font(.system(size: 15.5, weight: .bold, design: .rounded))
					.foregroundStyle(style.accent)
			}
		}
		.frame(height: 36)
	}
}

private struct RuleFilterSearchField: View {
	@Binding var text: String
	let placeholder: String
	let isFocused: FocusState<Bool>.Binding

	var body: some View {
		HStack(spacing: 9) {
			Image(systemName: "magnifyingglass")
				.font(.system(size: 17, weight: .semibold))
				.foregroundStyle(Color.dynamic(light: "#B3ACC0", dark: "#6B6478"))

			TextField(placeholder, text: $text)
				.font(.system(size: 15, weight: .regular, design: .rounded))
				.foregroundStyle(Color.softPrimaryText)
				.tint(.softAccent)
				.focused(isFocused)
				.textInputAutocapitalization(.never)
				.autocorrectionDisabled()
		}
		.padding(.horizontal, 14)
		.padding(.vertical, 11)
		.background(Color.softSurface, in: .rect(cornerRadius: 14, style: .continuous))
		.shadow(color: Color.softAccent.opacity(0.06), radius: 14, x: 0, y: 4)
	}
}

private struct RuleFilterSelectAllCard: View {
	let title: String
	let subtitle: String
	@Binding var isOn: Bool

	var body: some View {
		HStack(spacing: 13) {
			VStack(alignment: .leading, spacing: 2) {
				Text(title)
					.font(.system(size: 15.5, weight: .bold, design: .rounded))
					.foregroundStyle(Color.softPrimaryText)

				Text(subtitle)
					.font(.system(size: 12, weight: .regular, design: .rounded))
					.foregroundStyle(Color.softSecondaryText)
			}

			Spacer()

			Toggle("", isOn: $isOn)
				.labelsHidden()
				.tint(.softAccent)
		}
		.padding(.horizontal, 18)
		.padding(.vertical, 15)
		.background(Color.softSurface, in: .rect(cornerRadius: 16, style: .continuous))
		.shadow(color: Color.softAccent.opacity(0.07), radius: 18, x: 0, y: 6)
	}
}

private struct RuleFilterItemsPanel: View {
	let items: [String]
	let selectedItems: Set<String>
	let style: RuleFilterCategoryStyle
	let onToggle: (String) -> Void

	var body: some View {
		VStack(spacing: 0) {
			ForEach(items, id: \.self) { item in
				let isSelected = selectedItems.contains(item)

				Button {
					onToggle(item)
				} label: {
					HStack(spacing: 12) {
						Text(item)
							.font(.system(size: 15.5, weight: isSelected ? .semibold : .regular, design: .rounded))
							.foregroundStyle(Color.softPrimaryText)

						Spacer()

						SelectionIndicator(isSelected: isSelected, accent: style.accent)
					}
					.padding(.horizontal, 18)
					.padding(.vertical, 14)
					.background(isSelected ? style.selectedBackground : Color.softSurface)
				}
				.buttonStyle(.plain)

				if item != items.last {
					Divider()
						.background(Color.softDivider)
				}
			}
		}
		.background(Color.softSurface, in: .rect(cornerRadius: 18, style: .continuous))
		.clipShape(.rect(cornerRadius: 18, style: .continuous))
		.shadow(color: Color.softAccent.opacity(0.07), radius: 18, x: 0, y: 6)
	}
}

private struct SelectionIndicator: View {
	let isSelected: Bool
	let accent: Color

	var body: some View {
		ZStack {
			Circle()
				.fill(isSelected ? accent : .clear)
				.overlay {
					Circle()
						.stroke(isSelected ? accent : Color.dynamic(light: "#E0DBE8", dark: "#3D3850"), lineWidth: 2)
				}

			if isSelected {
				Image(systemName: "checkmark")
					.font(.system(size: 11, weight: .bold))
					.foregroundStyle(.white)
			}
		}
		.frame(width: 24, height: 24)
	}
}

private struct RuleFilterCategoryStyle {
	let symbolName: String
	let iconBackground: Color
	let accent: Color
	let selectedBackground: Color

	init(target: FilterTarget?) {
		self = Self.style(for: target)
	}

	private init(symbolName: String, iconBackground: Color, accent: Color, selectedBackground: Color) {
		self.symbolName = symbolName
		self.iconBackground = iconBackground
		self.accent = accent
		self.selectedBackground = selectedBackground
	}

	private static func style(for target: FilterTarget?) -> RuleFilterCategoryStyle {
		switch target {
		case .job:
			return RuleFilterCategoryStyle(
				symbolName: "briefcase",
				iconBackground: .softJobTint,
				accent: .softAccent,
				selectedBackground: .dynamic(light: "#F6F5FF", dark: "#272239")
			)
		case .department:
			return RuleFilterCategoryStyle(
				symbolName: "building.2",
				iconBackground: .softDepartmentTint,
				accent: .dynamic(light: "#E8895B", dark: "#E8A07B"),
				selectedBackground: .dynamic(light: "#FFF6F0", dark: "#33241F")
			)
		case .organization:
			return RuleFilterCategoryStyle(
				symbolName: "building",
				iconBackground: .softOrganizationTint,
				accent: .dynamic(light: "#2BA55D", dark: "#5FCB8A"),
				selectedBackground: .dynamic(light: "#F1FBF5", dark: "#1E2D26")
			)
		case .none:
			return RuleFilterCategoryStyle(
				symbolName: "line.3.horizontal.decrease.circle",
				iconBackground: .dynamic(light: "#F0EEF4", dark: "#302B3A"),
				accent: .softAccent,
				selectedBackground: .dynamic(light: "#F6F5FF", dark: "#272239")
			)
		}
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: RecipientsFilter.self, configurations: config)

	let filter = RecipientsFilter(target: .job, includes: nil, excludes: nil, all: true)
	container.mainContext.insert(filter)

	return NavigationStack {
		RuleFilterScreen(
			filter: filter
		)
	}
	.modelContainer(container)
}
