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
					Text("규칙 제목")
						.font(.headline)
						.foregroundColor(.title)
					
                    TextField("규칙 제목을 입력하세요", text: $viewModel.title)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.font(.body)
				}
				.padding(.horizontal, 20)
				.padding(.top, 20)
				
				// 필터 목록
				VStack(spacing: 16) {
					FilterRowView(
						title: "직책",
						subtitle: viewModel.getJobFilterText(),
						icon: "person.2.fill"
					) {
						selectedFilter = viewModel.getOrCreateFilter(for: "job")
					}
					
					FilterRowView(
						title: "부서",
						subtitle: viewModel.getDepartmentFilterText(),
						icon: "building.2.fill"
					) {
						selectedFilter = viewModel.getOrCreateFilter(for: "dept")
					}
					
					FilterRowView(
						title: "조직",
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
        .navigationTitle("규칙 수정")
		.navigationBarTitleDisplayMode(.large)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button("저장") {
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
			
            let filterViewModel = RuleFilterScreenModel(filter: filter)
            
            RuleFilterScreen(viewModel: filterViewModel)
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
