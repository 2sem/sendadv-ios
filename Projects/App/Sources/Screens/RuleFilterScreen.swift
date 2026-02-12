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
    
    init(filter: RecipientsFilter) {
        _viewModel = State(initialValue: RuleFilterScreenModel(filter: filter))
    }
    
    var body: some View {
        List {
            // All items toggle
            Toggle(isOn: Binding(
                get: { viewModel.selectAll },
                set: { newValue in
                    viewModel.toggleSelectAll(newValue)
                }
            )) {
                Text("Select All".localized())
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
//        .navigationTitle(viewModel.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done".localized()) {
                    viewModel.save(context: modelContext)
                    dismiss()
                }
                .tint(.accent)
            }
        }
        .onAppear {
            viewModel.loadItems()
        }
        .onDisappear {
            //
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
