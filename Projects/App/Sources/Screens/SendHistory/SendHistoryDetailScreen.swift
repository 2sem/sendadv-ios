//
//  SendHistoryDetailScreen.swift
//  App
//

import SwiftUI
import SwiftData

struct SendHistoryDetailScreen: View {
	let record: SendHistory
	let onResend: (SendHistory) -> Void

	@Environment(\.modelContext) private var modelContext
	@Environment(\.dismiss) private var dismiss
	@Environment(\.dynamicTypeSize) private var dynamicTypeSize
	@Query private var rules: [RecipientsRule]

	@State private var showingDeleteConfirmation = false
	@State private var deleteFeedbackCount = 0
	@State private var copyFeedbackCount = 0

	private var existingIDs: Set<UUID> {
		Set(rules.compactMap(\.uuid))
	}

	private var survivingCount: Int {
		SendHistoryRules.survivors(of: record.filterIDs, existing: existingIDs).kept.count
	}

	private var canResend: Bool {
		survivingCount > 0
	}

	var body: some View {
		ScrollView {
			VStack(spacing: 16) {
				summaryCard
				filtersCard
				messageCard
			}
			.padding(.horizontal, 30)
			.padding(.top, 12)
			.padding(.bottom, 24)
			.frame(maxWidth: 600)
			.frame(maxWidth: .infinity)
		}
		.scrollIndicators(.hidden)
		.background(Color.softBackground.ignoresSafeArea())
		.navigationTitle("history.detail.title".localized())
		.navigationBarTitleDisplayMode(.inline)
		.safeAreaInset(edge: .bottom, spacing: 0) {
			resendBar
		}
		.toolbar {
			ToolbarItem(placement: .topBarTrailing) {
				Button {
					showingDeleteConfirmation = true
				} label: {
					Image(systemName: "trash")
						.frame(minWidth: 44, minHeight: 44)
						.contentShape(Rectangle())
				}
				.tint(Color.softAccent)
				.accessibilityLabel("Delete".localized())
			}
		}
		.confirmationDialog(
			"history.delete.title".localized(),
			isPresented: $showingDeleteConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete".localized(), role: .destructive) {
				modelContext.delete(record)
				try? modelContext.save()
				deleteFeedbackCount += 1
				dismiss()
			}
			Button("Cancel".localized(), role: .cancel) { }
		}
		.sensoryFeedback(.warning, trigger: deleteFeedbackCount)
		.sensoryFeedback(.success, trigger: copyFeedbackCount)
	}

	// MARK: - Cards

	private var summaryCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			SendHistoryStatusPill(status: record.status, isLarge: true)

			Text(SendHistoryFormat.full(record.date))
				.font(.system(.title3, design: .rounded).weight(.bold))
				.foregroundStyle(Color.softPrimaryText)

			if record.status == .cancelled {
				Text(String(format: "history.cancelled.after".localized(), record.sentCount, record.totalCount))
					.font(.subheadline)
					.foregroundStyle(Color.softSecondaryText)
			} else {
				Text(String(format: "history.progress".localized(), record.sentCount, record.totalCount))
					.font(.subheadline.weight(.semibold))
					.foregroundStyle(Color.softPrimaryText)
			}

			if record.status == .partial {
				ProgressView(value: Double(record.sentCount), total: Double(max(record.totalCount, 1)))
					.tint(Color.softAccent)
					.accessibilityHidden(true)
			}

			Text("history.delivery.note".localized())
				.font(.footnote)
				.foregroundStyle(Color.softSecondaryText)
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.softFriendlyCard()
		.accessibilityElement(children: .combine)
	}

	private var filtersCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("history.section.filters".localized())
				.font(.footnote.weight(.semibold))
				.foregroundStyle(Color.softSecondaryText)
				.accessibilityAddTraits(.isHeader)

			if record.filterNames.isEmpty {
				Text("rule.row.allContacts".localized())
					.font(.body)
					.foregroundStyle(Color.softPrimaryText)
			} else {
				ForEach(Array(record.filterNames.enumerated()), id: \.offset) { index, name in
					filterRow(name: name, index: index)
				}
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.softFriendlyCard()
	}

	private func filterRow(name: String, index: Int) -> some View {
		let id = index < record.filterIDs.count ? record.filterIDs[index] : nil
		let isDeleted = id.map { !existingIDs.contains($0) } ?? true
		let displayName = name.isEmpty ? "New Rule".localized() : name
		return HStack(spacing: 8) {
			if isDeleted {
				Image(systemName: "slash.circle")
					.accessibilityHidden(true)
			}
			Text(isDeleted ? "\(displayName) \("history.filter.deleted".localized())" : displayName)
				.lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
		}
		.font(.body)
		.foregroundStyle(isDeleted ? Color.softSecondaryText.opacity(0.7) : Color.softPrimaryText)
		.frame(maxWidth: .infinity, alignment: .leading)
		.accessibilityElement(children: .combine)
	}

	private var messageCard: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("history.section.message".localized())
					.font(.footnote.weight(.semibold))
					.foregroundStyle(Color.softSecondaryText)
					.accessibilityAddTraits(.isHeader)
				Spacer()
				if !record.body.isEmpty {
					Button {
						UIPasteboard.general.string = record.body
						copyFeedbackCount += 1
					} label: {
						Label("history.copy".localized(), systemImage: "doc.on.doc")
							.font(.footnote.weight(.semibold))
							.frame(minHeight: 44)
							.contentShape(Rectangle())
					}
					.tint(Color.softAccent)
				}
			}

			if record.body.isEmpty {
				Text("history.message.empty".localized())
					.font(.body)
					.foregroundStyle(Color.softSecondaryText)
			} else {
				Text(record.body)
					.font(.body)
					.foregroundStyle(Color.softPrimaryText)
					.textSelection(.enabled)
					.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.softFriendlyCard()
	}

	// MARK: - Resend

	private var resendBar: some View {
		VStack(spacing: 8) {
			if !canResend && !record.filterIDs.isEmpty {
				Text("history.resend.none".localized())
					.font(.footnote)
					.foregroundStyle(Color.softSecondaryText)
					.multilineTextAlignment(.center)
			}

			Button {
				onResend(record)
			} label: {
				HStack(spacing: 12) {
					Image(systemName: "arrow.clockwise")
						.font(.headline.weight(.bold))
					Text("history.resend".localized())
				}
			}
			.buttonStyle(SoftFriendlyPrimaryButtonStyle())
			.disabled(!canResend)
			.opacity(canResend ? 1 : 0.5)
		}
		.padding(.horizontal, 30)
		.padding(.top, 12)
		.padding(.bottom, 24)
		.frame(maxWidth: .infinity)
		.background {
			LinearGradient(
				colors: [Color.softBackground.opacity(0), Color.softBackground.opacity(0.94), Color.softBackground],
				startPoint: .top,
				endPoint: .bottom
			)
			.ignoresSafeArea(.container, edges: .bottom)
			.allowsHitTesting(false)
		}
	}
}
