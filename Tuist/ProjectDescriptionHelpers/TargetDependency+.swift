//
//  TargetDependency+.swift
//  Config
//
//  Created by 영준 이 on 3/9/25.
//

import Foundation
import ProjectDescription

// MARK: Store Projects
public extension TargetDependency {
    class Projects {
        public static let ThirdParty: TargetDependency = .project(target: "ThirdParty",
                                               path: .projects("ThirdParty"))
        public static let DynamicThirdParty: TargetDependency = .project(target: "DynamicThirdParty",
                                               path: .projects("DynamicThirdParty"))
    }
}
