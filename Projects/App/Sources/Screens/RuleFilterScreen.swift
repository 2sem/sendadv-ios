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
    
    @State var viewModel: RuleFilterScreenModel
    
    var body: some View {
        List {
            // All items toggle
            Toggle(isOn: $viewModel.selectAll) {
                Text("모두 선택")
                    .font(.headline)
            }
            .padding(.vertical, 8)
            
            // Filter items list
            ForEach(viewModel.availableItems, id: \.self) { item in
                HStack {
                    Text(item)
                        .foregroundColor(.primary)
                    Spacer()
                    if viewModel.selectedItems.contains(item) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    viewModel.toggleItem(item)
                }
            }
        }
        .listStyle(PlainListStyle())
        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    viewModel.save()
                    dismiss()
                }
                .tint(.accent)
            }
        }
        .onAppear {
            viewModel.loadItems(using: modelContext)
        }
    }
}



#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: RecipientsFilter.self, configurations: config)
    
    let filter = RecipientsFilter(target: .job, includes: nil, excludes: nil, all: true)
    container.mainContext.insert(filter)
    
    let viewModel = RuleFilterScreenModel(filter: filter)
    
    return NavigationStack {
        RuleFilterScreen(
            viewModel: viewModel
        )
    }
    .modelContainer(container)
}
