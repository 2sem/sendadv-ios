//
//  RecipientListRowView.swift
//  App
//
//  Created by 영준 이 on 8/3/25.
//

import SwiftUI
import SwiftData

struct RecipientRuleRowView: View {
    let rule: RecipientsRule
    let onToggle: (Bool) -> Void
    
    var isTitleEmpty: Bool {
        return rule.title?.isEmpty ?? true
    }
    
    var body: some View {
        ZStack {
            // 배경색
            Color.background
            
            // 컨텐츠
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let title = rule.title, !title.isEmpty {
                        Text(title)
                    } else {
                        Text("수신자 생성 규칙")
                            .font(.headline)
                    }
                }
                .font(.headline)
                .foregroundStyle(Color.title)

                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { rule.enabled },
                    set: { onToggle($0) }
                )).padding(.trailing, 16)
            }
            .padding(.leading, 32)
            .padding(.trailing, 16)
        }
    }
}

struct RecipientRuleRowView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: RecipientsRule.self, configurations: config)
        
        let rule = RecipientsRule(title: "테스트 규칙", enabled: true)
        container.mainContext.insert(rule)
        
        return RecipientRuleRowView(rule: rule) { isOn in
            // Preview용 클로저
        }
        .previewLayout(.fixed(width: 350, height: 60))
        .modelContainer(container)
    }
}
