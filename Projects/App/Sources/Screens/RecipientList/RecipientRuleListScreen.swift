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

struct RecipientRuleListScreen: View {
    @Environment(\.modelContext) private var modelContext
    // 순서(order) 기준 정렬
    @Query(sort: \RecipientsRule.title) private var rules: [RecipientsRule]
    
    @State private var showingMessageComposer = false
    @State private var selectedRule: RecipientsRule?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingSettingsAlert = false
    @State private var viewModel = SARecipientListScreenModel()
    @State private var isEditing = false
    
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
					// 규칙 섹션
					Section {
//                        AdsView()
                        
						ForEach(rules, id: \.id) { rule in
							RecipientRuleRowView(rule: rule) { isEnabled in
								toggleRule(rule, isEnabled: isEnabled)
                            }
                            .frame(height: 100)
							.onTapGesture {
                                guard isEditing else { return }
                                selectedRule = rule
                            }
                            .if(isEditing) { view in
                                view.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        deleteRule(rule)
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
//                .onDelete {
//                    deleteRule(rules[$0])
//                }
                .listStyle(.plain)
//                .environment(\.editMode, $editMode)
//                .listRowBackground(Color.background)
//				.listStyle(InsetGroupedListStyle())
                
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
		.navigationTitle("수신자 목록 생성 규칙")
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
				if !rules.isEmpty {
                    Button(isEditing ? "취소" : "편집") {
                        isEditing.toggle()
                    }.tint(Color.accent)
				}
			}
			
			ToolbarItem(placement: .navigationBarTrailing) {
				Button("추가") {
					// 새 규칙 생성
					let newRule = RecipientsRule(title: "새 규칙", enabled: true)
					modelContext.insert(newRule)
					try? modelContext.save()
					
					// 새 규칙 편집 화면으로 이동
					selectedRule = newRule
                }.tint(Color.accent)
			}
		}
		.sheet(isPresented: $showingMessageComposer) {
			MessageComposerView(recipients: viewModel.phoneNumbers)
		}
		.alert("경고", isPresented: $showingAlert) {
			Button("계속") {
				onSendMessage(allowAll: true)
			}
			Button("취소", role: .cancel) { }
		} message: {
			Text(alertMessage)
		}
		.alert("연락처 접근 실패", isPresented: $showingSettingsAlert) {
			Button("설정") {
				if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
					UIApplication.shared.open(settingsUrl)
				}
			}
			Button("취소", role: .cancel) { }
		} message: {
			Text("연락처에 접근할 권한이 필요합니다.")
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
//		modelContext.delete(rule)
//		try? modelContext.save()
	}
	
    private func onSendMessage(allowAll: Bool = false) {
        Task { @MainActor in
            do {
                let phoneNumbers = try await viewModel.phoneNumbers(for: rules, allowAll: allowAll)
                
                viewModel.phoneNumbers = phoneNumbers
                showingMessageComposer = true
            } catch let sendMessageError as SendError {
                switch sendMessageError {
                    case .noRulesEnabled:
                        alertMessage = "활성화된 수신자 규칙이 없습니다.\n모든 연락처가 메시지를 받게 됩니다."
                        showingAlert = true
                    case .noContacts:
                        alertMessage = "활성화된 규칙과 일치하는 연락처가 없습니다."
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
    
    return NavigationStack {
        RecipientRuleListScreen()
    }
    .modelContainer(container)
}
