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
    @State private var isPreparingMessageView = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSettingsAlert = false
    @State private var viewModel = SARecipientListScreenModel()
    @State private var isEditing = false
    @State private var messageComposerState: MessageComposeState = .unknown
    @State private var skipPhoneNumberWarning = false
    
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
            Color.background
                .edgesIgnoringSafeArea(.all)
            
            if rules.isEmpty {
                EmptyStateView()
            } else {
                List {
                    // 규칙 섹션 + 네이티브 광고 섞어 보여주기
                    Section {
                        let interval = 5
                        ForEach(Array(rules.enumerated()), id: \.element.id) { index, rule in
                            Group {
                                NativeAdRowView(index: index, interval: interval)
                                // Added print statement for lifecycle tracking
                                let _ = print("RecipientRuleRowView init - rule id: \(rule.id), title: \(rule.title)")
                                RecipientRuleRowView(rule: rule) { isEnabled in
                                    toggleRule(rule, isEnabled: isEnabled)
                                }
                                .frame(height: 100)
                                .onTapGesture {
                                    guard isEditing else { return }
                                    
                                    presentFullAdThen { @MainActor in
                                        state = .editingRule(rule)
                                    }
                                }
                                .if(isEditing) { view in
                                    view.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            // Added print statement before deletion
                                            print("Deleting rule - id: \(rule.id), title: \(rule.title)")
                                            deleteRule(rule)
                                        } label: {
                                            Label("Delete".localized(), systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
            }
            
            // 전송 버튼
            if !rules.isEmpty {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        SendButton {
                            onSendMessage()
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationTitle("rules.title".localized())
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !rules.isEmpty {
                    Button(isEditing ? "Cancel".localized() : "Edit".localized()) {
                        isEditing.toggle()
                    }.tint(Color.accent)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("rules.add".localized()) {
                    // 전면 광고 후 새 규칙 편집 화면으로 이동
                    presentFullAdThen { @MainActor in
                        print("select new rule.")
                        state = .creatingRule
                    }
                }.tint(Color.accent)
            }
        }
        .sheet(isPresented: $showingMessageComposer) {
            MessageComposerView(recipients: viewModel.phoneNumbers, composeState: $messageComposerState)
        }
        .onChange(of: messageComposerState) {
            print("rule list screen detect message composer dismission. state[\(messageComposerState)]")
        #if DEBUG
            guard case .cancelled = messageComposerState else {
                return
            }
        #else
            guard case .sent = messageComposerState else {
                return
            }
        #endif
            
            LSDefaults.increaseMessageSentCount()
            reviewManager.show()
            
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
            if let newSelectedRule {
                return
            }
            
            state = .idle
        })
//        .onChange(of: state, handleStateChange)
        .overlay {
            if isPreparingMessageView {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                    .scaleEffect(1.5)
            }
        }
        .alert("Warning".localized(), isPresented: $showingAlert) {
            Button("Continue".localized()) {
                skipPhoneNumberWarning = true
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
        .navigationDestination(item: $selectedRule) { rule in
            RuleDetailScreen(rule: rule)
        }
    }
    
    private func toggleRule(_ rule: RecipientsRule, isEnabled: Bool) {
        viewModel.toggleRule(rule, isEnabled: isEnabled)
        try? modelContext.save()
    }
    
    private func deleteRule(_ rule: RecipientsRule) {
        viewModel.deleteRule(rule, modelContext: modelContext)
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
                let phoneNumbers = try await viewModel.phoneNumbers(for: rules, allowAll: allowAll)
                
                // 전화번호가 많으면 경고 표시 (skipPhoneNumberWarning이 false일 때만)
                if phoneNumbers.count > 100 && !skipPhoneNumberWarning {
                    alertMessage = "You are about to send message to \(phoneNumbers.count) recipients.\nThis may take a moment to load the message composer.".localized()
                    viewModel.phoneNumbers = phoneNumbers
                    showingAlert = true
                    return
                }
                
                skipPhoneNumberWarning = false
                viewModel.phoneNumbers = phoneNumbers
                showingMessageComposer = true
            } catch let sendMessageError as SendError {
                switch sendMessageError {
                    case .noRulesEnabled:
                        alertMessage = "There is no activated Rules for Reciepients.\nAll Contacts will receive Message.".localized()
                        showingAlert = true
                    case .noContacts:
                        alertMessage = "There is no contact matched to the enabled rules".localized()
                        showingAlert = true
                    case .permissionDenied:
                        showingSettingsAlert = true
                }
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

