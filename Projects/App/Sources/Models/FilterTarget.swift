//
//  TargetNames.swift
//  App
//
//  Created by Cascade on 2025. 8. 14..
//

import Foundation

enum FilterTarget: String, CaseIterable {
    case job = "job"
    case department = "dept"
    case organization = "org"
    
    var displayName: String {
        switch self {
        case .job: return "Job"
        case .department: return "Department"
        case .organization: return "Organization"
        }
    }
}
