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
	
	init(rule: RecipientsRule?) {
		_viewModel = State(initialValue: RuleDetailScreenModel(rule: rule))
	}
	
	var body: some View {
		ZStack {
            Color.background
				.edgesIgnoringSafeArea(.all)
			
			VStack(spacing: 20) {
				// 제목 입력 필드
				VStack(alignment: .leading, spacing: 8) {
					Text("Rule Title".localized())
						.font(.headline)
						.foregroundColor(.title)
					
					TextField("Enter rule title".localized(), text: $viewModel.title)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.font(.body)
				}
				.padding(.horizontal, 20)
				.padding(.top, 20)
				
				// 필터 목록
				VStack(spacing: 16) {
					FilterRowView(
						title: "Job".localized(),
						subtitle: viewModel.getJobFilterText(),
						icon: "person.2.fill"
					) {
						selectedFilter = viewModel.getOrCreateFilter(for: "job")
					}
					
					FilterRowView(
						title: "Department".localized(),
						subtitle: viewModel.getDepartmentFilterText(),
						icon: "building.2.fill"
					) {
						selectedFilter = viewModel.getOrCreateFilter(for: "dept")
					}
					
					FilterRowView(
						title: "Organization".localized(),
						subtitle: viewModel.getOrganizationFilterText(),
						icon: "building.fill"
					) {
						selectedFilter = viewModel.getOrCreateFilter(for: "org")
					}
				}
				.padding(.horizontal, 20)
				
				Spacer()
			}
		}
        			.navigationTitle("Edit Recipients Rule".localized())
		.navigationBarTitleDisplayMode(.large)
		.navigationBarBackButtonHidden(true)
		.toolbar {
			ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    print("커스텀 뒤로 가기 버튼이 눌렸습니다.")
                    // 필요한 로직 추가
                    dismiss()
                }) {
                    HStack(alignment: .center, spacing: 4) {
                        Image(systemName: "chevron.left")
                    }
                }.tint(.accent)
            }

			ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save".localized()) {
                    viewModel.save(using: modelContext)
					dismiss()
				}
				.tint(.accent)
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
		 .onDisappear {
             print("Rule Detail will be disappeared. isSaved[\(viewModel.isSaved)]")
            
             guard !viewModel.isSaved, let undoManager else {
                 return
             }
            
             viewModel.rollback(withUndoManager: undoManager)
         }
	}
}

struct FilterRowView: View {
	let title: String
	let subtitle: String
	let icon: String
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			HStack {
				Image(systemName: icon)
					.foregroundColor(.accent)
					.frame(width: 24, height: 24)
				
				VStack(alignment: .leading, spacing: 4) {
					Text(title)
						.font(.headline)
						.foregroundColor(.title)
					
					Text(subtitle)
						.font(.subheadline)
						.foregroundColor(.secondary)
				}
				
				Spacer()
				
				Image(systemName: "chevron.right")
					.foregroundColor(.secondary)
					.font(.caption)
			}
			.padding()
			.background(Color(.systemBackground))
			.cornerRadius(12)
			.shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
		}
		.buttonStyle(PlainButtonStyle())
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
