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

@Observable
class RuleFilterScreenModel {
    var selectAll: Bool = false
    var availableItems: [String] = []
    var selectedItems: Set<String> = []
    
    private(set) var filter: RecipientsFilter
    
    var title: String {
        FilterTarget(rawValue: filter.target ?? "")?.displayName.localized() ?? ""
    }
    
    init(filter: RecipientsFilter) {
        self.filter = filter
        
        // Load existing filter values
        self.selectAll = filter.all
        if !selectAll, let includes = filter.includes, !includes.isEmpty {
            self.selectedItems = Set(includes.components(separatedBy: ","))
        }
    }
    
    func loadItems(using context: ModelContext) {
        // Load available items based on target
//        switch filter.target {
//        case "job"?:
//            availableItems = (try? context.fetch(RecipientsRule.fetchJobs()))?.sorted() ?? []
//        case "dept"?:
//            availableItems = (try? context.fetch(RecipientsRule.fetchDepartments()))?.sorted() ?? []
//        case "org"?:
//            availableItems = (try? context.fetch(RecipientsRule.fetchOrganizations()))?.sorted() ?? []
//        default:
//            availableItems = []
//        }
        
        // If selectAll is true, select all available items
        if selectAll {
            selectedItems = Set(availableItems)
        }
    }
    
    func toggleItem(_ item: String) {
        if selectedItems.contains(item) {
            selectedItems.remove(item)
            selectAll = false
        } else {
            selectedItems.insert(item)
            // If all items are selected, update selectAll
            if selectedItems.count == availableItems.count {
                selectAll = true
            }
        }
    }
    
    func save() {
        // Update filter values
        filter.all = selectAll
        filter.includes = selectAll ? nil : selectedItems.sorted().joined(separator: ",")
        
        // Save changes
        do {
            try filter.modelContext?.save()
        } catch {
            print("Failed to save filter:", error)
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
