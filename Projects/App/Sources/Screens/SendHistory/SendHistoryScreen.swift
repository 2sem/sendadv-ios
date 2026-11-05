//
//  SendHistoryScreen.swift
//  App
//

import SwiftUI
import SwiftData

struct SendHistoryScreen: View {
	@Environment(\.modelContext) private var modelContext
	@Query(sort: \SendHistory.date, order: .reverse) private var histories: [SendHistory]

	/// Called when the user resends from a detail screen. The owner pops back and presents the send flow.
	let onResend: (SendHistory) -> Void

	@State private var selectedRecord: SendHistory?
	@State private var recordPendingDeletion: SendHistory?
	@State private var showingDeleteConfirmation = false
	@State private var showingClearConfirmation = false
	@State private var deleteFeedbackCount = 0
	@State private var isAdFree: Bool = LSDefaults.isAdFree

	private var groups: [SendHistoryRules.DayGroup<SendHistory>] {
		SendHistoryRules.grouped(histories, date: \.date)
	}

	var body: some View {
		Group {
			if histories.isEmpty {
				emptyView
			} else {
				historyList
			}
		}
		.background(Color.softBackground.ignoresSafeArea())
		.navigationTitle("history.title".localized())
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button("history.clear.all".localized(), role: .destructive) {
					showingClearConfirmation = true
				}
				.disabled(histories.isEmpty)
			}
		}
		.navigationDestination(item: $selectedRecord) { record in
			SendHistoryDetailScreen(record: record, onResend: onResend)
		}
		.confirmationDialog(
			"history.delete.title".localized(),
			isPresented: $showingDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete".localized(), role: .destructive) {
				if let record = recordPendingDeletion {
					delete(record)
				}
				recordPendingDeletion = nil
			}
			Button("Cancel".localized(), role: .cancel) {
				recordPendingDeletion = nil
			}
		}
		.confirmationDialog(
			"history.clear.title".localized(),
			isPresented: $showingClearConfirmation,
			titleVisibility: .visible
		) {
			Button("history.clear.confirm".localized(), role: .destructive) {
				clearAll()
			}
			Button("Cancel".localized(), role: .cancel) { }
		} message: {
			Text("history.clear.message".localized())
		}
		.sensoryFeedback(.warning, trigger: deleteFeedbackCount)
	}

	// MARK: - Subviews

	private var emptyView: some View {
		ContentUnavailableView {
			Label("history.empty.title".localized(), systemImage: "clock.arrow.circlepath")
		} description: {
			Text("history.empty.message".localized())
		}
	}

	private var historyList: some View {
		ScrollView {
			LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
				ForEach(groups, id: \.day) { group in
					Section {
						ForEach(group.items) { record in
							row(for: record)
						}
					} header: {
						dayHeader(group.day)
					}
				}

				Text("history.footer".localized())
					.font(.footnote)
					.foregroundStyle(Color.softSecondaryText)
					.frame(maxWidth: .infinity, alignment: .center)
					.multilineTextAlignment(.center)
					.padding(.top, 8)

				if !isAdFree {
					NativeAdRowView()
						.padding(.top, 24)
				}
			}
			.padding(.horizontal, 30)
			.padding(.bottom, 24)
			.frame(maxWidth: 600)
			.frame(maxWidth: .infinity)
		}
		.scrollIndicators(.hidden)
	}

	private func dayHeader(_ day: Date) -> some View {
		Text(SendHistoryFormat.dayTitle(day))
			.font(.footnote.weight(.semibold))
			.foregroundStyle(Color.softSecondaryText)
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding(.vertical, 8)
			.padding(.horizontal, 4)
			.background(.ultraThinMaterial)
			.accessibilityAddTraits(.isHeader)
	}

	private func row(for record: SendHistory) -> some View {
		Button {
			selectedRecord = record
		} label: {
			SendHistoryRowView(record: record)
		}
		.buttonStyle(.plain)
		.contextMenu {
			Button(role: .destructive) {
				requestDelete(record)
			} label: {
				Label("Delete".localized(), systemImage: "trash")
			}
		}
		.accessibilityHint("history.row.hint".localized())
		.accessibilityAction(named: Text("Delete".localized())) {
			requestDelete(record)
		}
	}

	// MARK: - Actions

	private func requestDelete(_ record: SendHistory) {
		recordPendingDeletion = record
		showingDeleteConfirmation = true
	}

	private func delete(_ record: SendHistory) {
		modelContext.delete(record)
		try? modelContext.save()
		deleteFeedbackCount += 1
	}

	private func clearAll() {
		for record in histories {
			modelContext.delete(record)
		}
		try? modelContext.save()
		deleteFeedbackCount += 1
	}
}

private struct SendHistoryRowView: View {
	let record: SendHistory
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize

	private var isAccessibilitySize: Bool { dynamicTypeSize.isAccessibilitySize }

	private var filterSummary: String {
		let names = record.filterNames.map { $0.isEmpty ? "New Rule".localized() : $0 }
		guard !names.isEmpty else { return "rule.row.allContacts".localized() }
		if isAccessibilitySize || names.count <= 3 {
			return names.joined(separator: " · ")
		}
		return names.prefix(3).joined(separator: " · ") + " " + String(format: "history.filters.more".localized(), names.count - 3)
	}

	private var accessibilitySummary: String {
		var parts = [
			"\(SendHistoryFormat.dayTitle(Calendar.current.startOfDay(for: record.date))) \(SendHistoryFormat.time(record.date))",
			record.status.titleKey.localized(),
			String(format: "history.progress".localized(), record.sentCount, record.totalCount),
			filterSummary,
		]
		if !record.body.isEmpty { parts.append(record.body) }
		return parts.joined(separator: ", ")
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			header

			Text(filterSummary)
				.font(.system(.headline, design: .rounded))
				.foregroundStyle(Color.softPrimaryText)
				.lineLimit(isAccessibilitySize ? nil : 2)
				.multilineTextAlignment(.leading)

			if !record.body.isEmpty {
				Text(record.body)
					.font(.footnote)
					.foregroundStyle(Color.softSecondaryText)
					.lineLimit(isAccessibilitySize ? nil : 2)
					.multilineTextAlignment(.leading)
			}

			HStack(spacing: 6) {
				Image(systemName: "person.2")
				Text("\(record.sentCount) recipients", tableName: "Plural")
				Spacer(minLength: 8)
				Image(systemName: "chevron.right")
					.font(.caption.weight(.bold))
			}
			.font(.footnote.weight(.semibold))
			.foregroundStyle(Color.softSecondaryText)
		}
		.padding(.horizontal, 20)
		.padding(.vertical, 16)
		.frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
		.softFriendlyCard()
		.contentShape(Rectangle())
		.accessibilityElement(children: .combine)
		.accessibilityLabel(accessibilitySummary)
	}

	@ViewBuilder
	private var header: some View {
		if isAccessibilitySize {
			VStack(alignment: .leading, spacing: 6) {
				Text(SendHistoryFormat.time(record.date))
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.softPrimaryText)
				SendHistoryStatusPill(status: record.status)
			}
		} else {
			HStack {
				Text(SendHistoryFormat.time(record.date))
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.softPrimaryText)
				Spacer(minLength: 8)
				SendHistoryStatusPill(status: record.status)
			}
		}
	}
}
