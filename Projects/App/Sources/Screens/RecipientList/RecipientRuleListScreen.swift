//
//  SARecipientListScreen.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import MessageUI
import Contacts
import SwiftData
import StoreKit
import Combine
import TipKit

private struct AccentTipViewStyle: TipViewStyle {
	func makeBody(configuration: TipViewStyleConfiguration) -> some View {
		VStack(alignment: .leading, spacing: 10) {
			VStack(alignment: .leading, spacing: 4) {
				configuration.title
					.font(.headline)
				configuration.message?
					.font(.subheadline)
					.foregroundStyle(.secondary)
			}
			if !configuration.actions.isEmpty {
				HStack {
					ForEach(configuration.actions) { action in
						Button(action: action.handler) {
							action.label()
						}
						.foregroundStyle(Color.softAccentLabel)
						.buttonStyle(.borderedProminent)
						.tint(.softAccent)
					}
					Spacer()
				}
			}
		}
		.padding()
	}
}

struct RecipientRuleListScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.undoManager) private var undoManager
    @EnvironmentObject private var adManager: SwiftUIAdManager
    @EnvironmentObject private var reviewManager: ReviewManager
    // 순서(order) 기준 정렬
    @Query(sort: \RecipientsRule.title) private var rules: [RecipientsRule]

    @AppStorage("LaunchCount") var launchCount: Int = 0

#if DEBUG
    var nativeAdUnit: String = "ca-app-pub-3940256099942544/3986624511"
#else
    @InfoPlist(["GADUnitIdentifiers", "Native"], default: "") var nativeAdUnit: String
#endif

    @State private var state: SARecipientListScreenModel.State = .idle
    @State private var selectedRule: RecipientsRule?

    @State private var showingMessageComposer = false
    @State private var showingSendConfirmationSheet = false
    @State private var isPreparingMessageView = false
	@State private var isMessageComposerLoading = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSettingsAlert = false
    @State private var showingNoContactsAlert = false
    @State private var viewModel = SARecipientListScreenModel()
    @State private var messageComposerState: MessageComposeState = .unknown
	@State private var isBatchSending = false
	@State private var allPhoneNumbers: [String] = []
	@State private var currentBatchIndex: Int = 0
	@State private var activeBatchNumber: Int = 1
	@State private var totalBatchCount: Int = 1
	@State private var totalRecipientCount: Int = 0
	@State private var batchProgressText: String = ""
	@State private var isAdFree: Bool = LSDefaults.isAdFree
	@State private var isEditingRules = false
	@State private var rulePendingDeletion: RecipientsRule?
	@State private var showingDeleteRuleConfirmation = false
	@State private var showingMessageUnavailableAlert = false
	@State private var sendConfirmationSheetHeight: CGFloat = 428
	@State private var sendButtonFrame: CGRect = .zero
	private let sendButtonBottomPadding: CGFloat = 24
	private let scrollBottomClearance: CGFloat = 16
	private let screenCoordinateSpace = "RecipientRuleListScreen"
	    private let batchSize: Int = 20
	    private let addFirstFilterTip = AddFirstFilterTip()
	    @State private var isAddFirstFilterTipVisible = false

	private var enabledRuleCount: Int {
		rules.filter(\.enabled).count
	}

	private var scrollBottomPadding: CGFloat {
		guard !isEditingRules, sendButtonFrame != .zero else { return 0 }
		return sendButtonFrame.height + sendButtonBottomPadding + scrollBottomClearance
	}

	private var bottomContentFade: some View {
		GeometryReader { proxy in
			let buttonBottomLocation = proxy.size.height > 0 ? min(max(sendButtonFrame.height / proxy.size.height, 0), 1) : 0
			let remainingLocation = 1 - buttonBottomLocation

			LinearGradient(
				stops: [
					.init(color: Color.softBackground.opacity(0), location: 0),
					.init(color: Color.softBackground.opacity(0), location: buttonBottomLocation),
					.init(color: Color.softBackground.opacity(0.68), location: buttonBottomLocation + remainingLocation * 0.32),
					.init(color: Color.softBackground.opacity(0.94), location: buttonBottomLocation + remainingLocation * 0.65),
					.init(color: Color.softBackground, location: 1)
				],
				startPoint: .top,
				endPoint: .bottom
			)
		}
		.ignoresSafeArea(.container, edges: .bottom)
		.allowsHitTesting(false)
		.accessibilityHidden(true)
	}

	    private func presentFullAdThen(_ action: @escaping () -> Void) {
	        guard launchCount > 1 else {
	            action()
	            return
	        }
        Task {
            await adManager.requestAppTrackingIfNeed()

            await adManager.show(unit: .full)

            action()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            viewModel.remove(offsets.map { rules[$0] })
            offsets.forEach { index in
                let rule = rules[index]
                modelContext.delete(rule)
            }
            try? modelContext.save()
        }
    }

	var body: some View {
		ZStack {
			Color.softBackground
				.ignoresSafeArea()

			ScrollView {
				LazyVStack(spacing: 12) {
					if !rules.isEmpty {
						RuleListStatusView(enabledCount: enabledRuleCount)
							.padding(.bottom, 0)
					}

					ForEach(rules) { rule in
						RecipientRuleRowView(
							rule: rule,
							isEditing: isEditingRules,
							onToggle: { isEnabled in
								toggleRule(rule, isEnabled: isEnabled)
							},
							onDelete: {
								requestDeleteRule(rule)
							}
						)
						.onTapGesture {
							guard !isEditingRules else { return }
							state = .editingRule(rule)
						}
						.contextMenu {
							if !isEditingRules {
								Button(role: .destructive) {
									requestDeleteRule(rule)
								} label: {
									Label("Delete".localized(), systemImage: "trash")
								}
							}
						}
					}

					if !rules.isEmpty && !isAdFree {
						NativeAdRowView()
							.padding(.top, 58)
					}
				}
				.padding(.top, 12)
				.padding(.horizontal, 30)
				.padding(.bottom, scrollBottomPadding)
			}
			.scrollIndicators(.hidden)
			.overlay {
				if rules.isEmpty {
					EmptyStateView {
						state = .creatingRule
					}
				}
			}

			if !rules.isEmpty && !isEditingRules {
				GeometryReader { proxy in
					VStack(spacing: 0) {
						Spacer()

						bottomContentFade
							.frame(height: sendButtonFrame == .zero ? 0 : max(0, proxy.size.height + proxy.safeAreaInsets.bottom - sendButtonFrame.minY))
					}
				}
				.allowsHitTesting(false)
				.accessibilityHidden(true)
			}

			// 전송 버튼
			if !rules.isEmpty && !isEditingRules {
				VStack {
					Spacer()
					HStack(alignment: .center) {
						SendButton(title: String(format: "send.action.with.count".localized(), enabledRuleCount)) {
							onSendMessage()
						}
					}
					.frame(maxWidth: .infinity)
					.padding(.horizontal, 30)
					.readFrame(in: .named(screenCoordinateSpace)) { sendButtonFrame = $0 }
					.padding(.bottom, sendButtonBottomPadding)
				}
			}
		}
		.coordinateSpace(name: screenCoordinateSpace)
		.navigationTitle("rules.header.title".localized())
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				if !rules.isEmpty {
					Button {
						withAnimation(.easeInOut(duration: 0.2)) {
							isEditingRules.toggle()
						}
					} label: {
						if isEditingRules {
							Image(systemName: "checkmark")
						} else {
							Text("Edit".localized())
						}
					}
					.font(.headline.weight(.semibold))
					.foregroundStyle(Color.softAccent)
					.accessibilityLabel((isEditingRules ? "Done" : "Edit").localized())
				}
			}

			ToolbarItem(placement: .topBarTrailing) {
				if !isEditingRules {
					Button {
						if isAddFirstFilterTipVisible {
							addFirstFilterTip.logActionTaken()
						}
						state = .creatingRule
					} label: {
						Image(systemName: "plus")
					}
					.tint(Color.softAccent)
					.popoverTip(addFirstFilterTip, arrowEdge: .top) { _ in
						addFirstFilterTip.logActionTaken()
						state = .creatingRule
					}
					.task {
						var previousShouldDisplay = false
						for await shouldDisplay in addFirstFilterTip.shouldDisplayUpdates {
							isAddFirstFilterTipVisible = shouldDisplay
							if shouldDisplay {
								addFirstFilterTip.logShown(isFirstLaunch: launchCount <= 1)
							} else if previousShouldDisplay && !shouldDisplay {
								// 팁이 표시되었다가 닫힘 (어떤 방식으로든)
								AddFirstFilterTip.shownThisLaunch = true
							}
							previousShouldDisplay = shouldDisplay
						}
					}
				}
			}
		}
        .tipViewStyle(AccentTipViewStyle())
		.onChange(of: rules.count) { oldValue, newValue in
			if newValue == 0 {
				isEditingRules = false
			}
			// 필터 개수에 따라 팁 표시 조건 업데이트
			Task { @MainActor in
                AddFirstFilterTip.hasFilters = !rules.isEmpty
            }
        }
        .onAppear {
            // 초기 로드 시 필터 상태 설정 (shownThisLaunch는 .transient로 자동 초기화됨)
            Task { @MainActor in
                AddFirstFilterTip.hasFilters = !rules.isEmpty
            }
        }
        .onReceive(Timer.publish(every: 30, on: .main, in: .common).autoconnect()) { _ in
            isAdFree = LSDefaults.isAdFree
        }
        .animation(.easeInOut(duration: 0.25), value: isAdFree)
        .sheet(isPresented: $showingMessageComposer) {
			ZStack {
				MessageComposerView(
					recipients: viewModel.phoneNumbers,
					composeState: $messageComposerState,
					isLoading: $isMessageComposerLoading
				)

				if isMessageComposerLoading {
					Color.black.opacity(0.4)
						.edgesIgnoringSafeArea(.all)

					VStack(spacing: 16) {
						ProgressView()
							.progressViewStyle(CircularProgressViewStyle(tint: .white))
							.scaleEffect(1.5)

						Text("Getting started to write\nIt will take much longer for many recipients.".localized())
							.foregroundColor(.white)
							.multilineTextAlignment(.center)
							.font(.system(size: 14))

						if !batchProgressText.isEmpty {
							Text(batchProgressText)
								.foregroundColor(.white.opacity(0.8))
								.multilineTextAlignment(.center)
								.font(.system(size: 12))
						}
					}
				}
			}
        }
		.sheet(isPresented: $showingSendConfirmationSheet) {
			sendConfirmationSheet
		}
		.onChange(of: messageComposerState) {
            guard messageComposerState != .unknown else {
                return
            }

			print("rule list screen detect message composer dismission. state[\(messageComposerState)]")
			// 배치 전송 처리: 사용자가 취소하지 않은 경우 다음 배치를 자동 진행
			if isBatchSending {
				let isCancelled: Bool = {
		#if DEBUG
					// 시뮬레이터는 .sent를 반환하지 못하므로 .cancelled를 성공으로 간주
					return false
		#else
					return messageComposerState == .cancelled
		#endif
				}()

				if isCancelled {
					// 사용자가 취소하면 배치 전송 중단
					isBatchSending = false
					allPhoneNumbers = []
					currentBatchIndex = 0
				} else {
					let isBatchComplete = presentNextBatch()
					// 배치 마지막 전송 완료 시에만 카운트 증가 + 리뷰 요청 + 전면 광고
					if isBatchComplete {
						LSDefaults.increaseMessageSentCount()
						if reviewManager.canShow {
							reviewManager.show()
						}
						presentFullAdThen {}
					}
				}

                messageComposerState = .unknown
                return
			}

			// 발송 성공 시 카운트 증가 후 5회째에서 성공 팝업 + 리뷰 요청
			let isSent: Bool = {
		#if DEBUG
				if case .cancelled = messageComposerState { return true }
				return false
		#else
				if case .sent = messageComposerState { return true }
				return false
		#endif
			}()

			if isSent {
				LSDefaults.increaseMessageSentCount()
				// 5회 성공 시에만 App Store 리뷰 요청
				if reviewManager.canShow {
					reviewManager.show()
				}
				presentFullAdThen {}
			}
			messageComposerState = .unknown
		}
        .onChange(of: state, { _, newState in
            switch newState {
            case .creatingRule:
                // 새 규칙 생성
                guard let newRule = viewModel.createRule(modelContext: modelContext, undoManager: undoManager) else {
                    return
                }

                state = .editingRule(newRule)
            case .editingRule(let newRule):
                selectedRule = newRule
            case .idle:
                break
            }
        })
        .onChange(of: selectedRule, { _, newSelectedRule in
            if newSelectedRule != nil {
                return
            }

            state = .idle
        })
//        .onChange(of: state, handleStateChange)
        .overlay {
            if isPreparingMessageView {
	                ProgressView()
	                    .progressViewStyle(CircularProgressViewStyle(tint: .softAccent))
	                    .scaleEffect(1.5)
            }
        }

		.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
			print("keyboard will show on rule list screen")
		}
		.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
			print("keyboard will hide on rule list screen")
		}
        .alert("Warning".localized(), isPresented: $showingAlert) {
			Button("Continue".localized()) {
				onSendMessage(allowAll: true)
			}
            Button("Cancel".localized(), role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("Failed to access contacts".localized(), isPresented: $showingSettingsAlert) {
            Button("Setting".localized()) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("Cancel".localized(), role: .cancel) { }
        } message: {
            Text("Permission required to acess contacts for creating recipients list".localized())
        }
		.alert("Warning".localized(), isPresented: $showingNoContactsAlert) {
			Button("OK".localized(), role: .cancel) { }
		} message: {
			Text("There is no contact matched to the enabled rules".localized())
		}
		.confirmationDialog(
			"rule.delete.confirmation.title".localized(),
			isPresented: $showingDeleteRuleConfirmation,
			titleVisibility: .visible
		) {
			Button("Delete".localized(), role: .destructive) {
				if let rule = rulePendingDeletion {
					deleteRule(rule)
				}
				rulePendingDeletion = nil
			}
			Button("Cancel".localized(), role: .cancel) {
				rulePendingDeletion = nil
			}
		} message: {
			Text("rule.delete.confirmation.message".localized())
		}
		.alert("send.unavailable.title".localized(), isPresented: $showingMessageUnavailableAlert) {
			Button("OK".localized(), role: .cancel) { }
		} message: {
			Text("send.unavailable.message".localized())
		}
		.navigationDestination(item: $selectedRule) { rule in
			RuleDetailScreen(rule: rule)
        }
    }

	private var sendConfirmationSheet: some View {
		SendConfirmationSheet(
			recipientCount: totalRecipientCount,
			batchRecipientCount: viewModel.phoneNumbers.count,
			batchSize: batchSize,
			activeBatchNumber: activeBatchNumber,
			totalBatchCount: totalBatchCount,
			onCancel: cancelSendConfirmation,
			onContinue: continueFromSendConfirmation
		)
		.readHeight { height in
			let measuredHeight = min(max(height + 12, 320), 620)
			guard abs(sendConfirmationSheetHeight - measuredHeight) > 1 else { return }
			sendConfirmationSheetHeight = measuredHeight
		}
		.presentationDetents([.height(sendConfirmationSheetHeight)])
		.presentationDragIndicator(.visible)
		.presentationBackground(Color.softSurface)
	}

    private func toggleRule(_ rule: RecipientsRule, isEnabled: Bool) {
        viewModel.toggleRule(rule, isEnabled: isEnabled)
        try? modelContext.save()
    }

	private func deleteRule(_ rule: RecipientsRule) {
		viewModel.deleteRule(rule, modelContext: modelContext)
	}

	private func requestDeleteRule(_ rule: RecipientsRule) {
		rulePendingDeletion = rule
		showingDeleteRuleConfirmation = true
	}

    private func onSendMessage(allowAll: Bool = false) {
        // 규칙이 설정되었는지 확인
        let enabledRules = rules.filter { $0.enabled }
        if enabledRules.isEmpty && !allowAll {
            alertMessage = "There is no activated Rules for Reciepients.\nAll Contacts will receive Message.".localized()
            showingAlert = true
            return
        }

        isPreparingMessageView = true

        Task { @MainActor in
            defer { isPreparingMessageView = false }
            do {
				let _phoneNumbers = try await viewModel.phoneNumbers(for: rules, allowAll: allowAll)
				let phoneNumbers = Array(_phoneNumbers)

				if phoneNumbers.count > batchSize {
					allPhoneNumbers = phoneNumbers
					isBatchSending = true
					currentBatchIndex = 0
					totalRecipientCount = phoneNumbers.count
					totalBatchCount = Int(ceil(Double(phoneNumbers.count) / Double(batchSize)))
					presentNextBatch()
				} else {
					// 소량이면 단일 표시
					viewModel.phoneNumbers = phoneNumbers
					totalRecipientCount = phoneNumbers.count
					totalBatchCount = 1
					activeBatchNumber = 1
					batchProgressText = ""
					presentSendConfirmation()
				}
            } catch let sendMessageError as SendError {
                switch sendMessageError {
                    case .noRulesEnabled:
                        alertMessage = "There is no activated Rules for Reciepients.\nAll Contacts will receive Message.".localized()
                        showingAlert = true
                    case .noContacts:
                        showingNoContactsAlert = true
                    case .permissionDenied:
                        showingSettingsAlert = true
                }
            }
        }
    }

	@discardableResult private func presentNextBatch() -> Bool {
		guard isBatchSending else { return false }
		let start = currentBatchIndex * batchSize
		guard start < allPhoneNumbers.count else {
			isBatchSending = false
			allPhoneNumbers = []
			currentBatchIndex = 0
			activeBatchNumber = 1
			totalBatchCount = 1
			totalRecipientCount = 0
			batchProgressText = ""
			return true
		}
		let end = min(start + batchSize, allPhoneNumbers.count)
		let batch = Array(allPhoneNumbers[start..<end])
		let totalBatches = Int(ceil(Double(allPhoneNumbers.count) / Double(batchSize)))
		let currentNumber = currentBatchIndex + 1
		totalRecipientCount = allPhoneNumbers.count
		totalBatchCount = totalBatches
		activeBatchNumber = currentNumber
		batchProgressText = String(format: "send.batch.progress".localized(), currentNumber, totalBatches, batch.count)
		viewModel.phoneNumbers = batch
		presentSendConfirmation()
		currentBatchIndex += 1
		return false
	}

	private func presentSendConfirmation() {
		isMessageComposerLoading = false
		showingMessageComposer = false
		showingSendConfirmationSheet = true
	}

	private func cancelSendConfirmation() {
		showingSendConfirmationSheet = false
		isBatchSending = false
		allPhoneNumbers = []
		currentBatchIndex = 0
		activeBatchNumber = 1
		totalBatchCount = 1
		totalRecipientCount = 0
		batchProgressText = ""
	}

	private func continueFromSendConfirmation() {
		showingSendConfirmationSheet = false
		Task { @MainActor in
			try? await Task.sleep(for: .milliseconds(250))
			presentMessageComposer()
		}
	}

	@discardableResult private func presentMessageComposer() -> Bool {
		guard MFMessageComposeViewController.canSendText() else {
			isBatchSending = false
			allPhoneNumbers = []
			currentBatchIndex = 0
			activeBatchNumber = 1
			totalBatchCount = 1
			totalRecipientCount = 0
			batchProgressText = ""
			isMessageComposerLoading = false
			showingMessageComposer = false
			showingMessageUnavailableAlert = true
			return false
		}

		isMessageComposerLoading = true
		showingMessageComposer = true
		return true
	}
}


private struct RuleListStatusView: View {
	let enabledCount: Int

	var body: some View {
		Text(String(format: "rules.header.summary".localized(), enabledCount))
			.font(.title3.weight(.bold))
			.foregroundStyle(Color.softSecondaryText)
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

private struct SendConfirmationSheet: View {
	let recipientCount: Int
	let batchRecipientCount: Int
	let batchSize: Int
	let activeBatchNumber: Int
	let totalBatchCount: Int
	let onCancel: () -> Void
	let onContinue: () -> Void

	private var isBatchSending: Bool {
		totalBatchCount > 1
	}

	private var isContinuingBatch: Bool {
		isBatchSending && activeBatchNumber > 1
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 26) {
			Image(systemName: "bubble.left")
				.font(.system(size: 42, weight: .regular))
				.foregroundStyle(Color.softAccent)
				.frame(width: 104, height: 104)
				.background(Color.softAccent.opacity(0.11), in: .rect(cornerRadius: 31, style: .continuous))

			VStack(alignment: .leading, spacing: 14) {
				Text((isContinuingBatch ? "send.confirmation.continue.title" : "send.confirmation.title").localized())
					.font(.system(size: 31, weight: .bold, design: .rounded))
					.foregroundStyle(Color.softPrimaryText)

				confirmationMessage
					.font(.system(size: 20, weight: .semibold, design: .rounded))
					.foregroundStyle(Color.softSecondaryText)
					.multilineTextAlignment(.leading)
					.lineSpacing(6)
					.lineLimit(nil)
					.fixedSize(horizontal: false, vertical: true)

				if isBatchSending {
					VStack(alignment: .leading, spacing: 8) {
						Text(String(format: "send.confirmation.batch.progress".localized(), activeBatchNumber, totalBatchCount, batchRecipientCount))
							.font(.system(size: 13, weight: .bold, design: .rounded))
							.foregroundStyle(Color.softAccent)

						ProgressView(value: Double(activeBatchNumber), total: Double(totalBatchCount))
							.tint(Color.softAccent)
					}
					.padding(.horizontal, 14)
					.padding(.vertical, 10)
					.background(Color.softAccent.opacity(0.12), in: .rect(cornerRadius: 16, style: .continuous))
				}

				Text("send.confirmation.helper".localized())
					.font(.system(size: 13, weight: .semibold, design: .rounded))
					.foregroundStyle(Color.softSecondaryText.opacity(0.9))
					.multilineTextAlignment(.leading)
					.lineSpacing(3)
					.lineLimit(nil)
					.fixedSize(horizontal: false, vertical: true)
			}

			VStack(spacing: 10) {
				Button(action: onContinue) {
					HStack(spacing: 18) {
						Image(systemName: "paperplane.fill")
							.font(.system(size: 22, weight: .bold))
						Text(primaryButtonTitle)
					}
				}
				.buttonStyle(SoftFriendlyPrimaryButtonStyle())

				Button(secondaryButtonTitle, role: .cancel, action: onCancel)
					.font(.system(size: 17, weight: .bold, design: .rounded))
					.foregroundStyle(Color.softSecondaryText)
					.frame(maxWidth: .infinity, minHeight: 44)
			}
			.padding(.top, 4)
		}
		.padding(.horizontal, 36)
		.padding(.top, 38)
		.padding(.bottom, 28)
		.frame(maxWidth: .infinity, alignment: .topLeading)
		.background(Color.softSurface)
	}

	private var confirmationMessage: Text {
		let countText = Text(String(format: "send.confirmation.message.count".localized(), recipientCount))
			.foregroundStyle(Color.softAccent)
			.fontWeight(.bold)

		if isBatchSending {
			return Text("send.confirmation.batch.message.prefix".localized())
				+ countText
				+ Text(String(format: "send.confirmation.batch.message.suffix".localized(), totalBatchCount, batchSize))
		}

		return Text("send.confirmation.message.prefix".localized())
			+ countText
			+ Text("send.confirmation.message.suffix".localized())
	}

	private var primaryButtonTitle: String {
		"send.confirmation.openMessages".localized()
	}

	private var secondaryButtonTitle: String {
		(isContinuingBatch ? "send.confirmation.stop" : "send.confirmation.notNow").localized()
	}
}

private struct ViewHeightPreferenceKey: PreferenceKey {
	static var defaultValue: CGFloat = 0

	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = max(value, nextValue())
	}
}

private struct ViewFramePreferenceKey: PreferenceKey {
	static var defaultValue: CGRect = .zero

	static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}

private extension View {
	func readHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
		background {
			GeometryReader { proxy in
				Color.clear
					.preference(key: ViewHeightPreferenceKey.self, value: proxy.size.height)
			}
		}
		.onPreferenceChange(ViewHeightPreferenceKey.self) { height in
			DispatchQueue.main.async {
				onChange(height)
			}
		}
	}

	func readFrame(in coordinateSpace: CoordinateSpace, _ onChange: @escaping (CGRect) -> Void) -> some View {
		background {
			GeometryReader { proxy in
				Color.clear
					.preference(key: ViewFramePreferenceKey.self, value: proxy.frame(in: coordinateSpace))
			}
		}
		.onPreferenceChange(ViewFramePreferenceKey.self) { frame in
			DispatchQueue.main.async {
				onChange(frame)
			}
		}
	}
}




#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: RecipientsRule.self, configurations: config)

    // 샘플 규칙 추가
    let rule1 = RecipientsRule(title: "회사 동료들", enabled: true, order: 1)
    let rule2 = RecipientsRule(title: "가족", enabled: false, order: 2)
    let rule3 = RecipientsRule(title: "학교 친구들", enabled: true, order: 3)

    container.mainContext.insert(rule1)
    container.mainContext.insert(rule2)
    container.mainContext.insert(rule3)

    let adManager = SwiftUIAdManager()
    return NavigationStack {
        RecipientRuleListScreen()
    }
    .modelContainer(container)
    .environmentObject(adManager)
}
