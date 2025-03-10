//
//  Workspace.swift
//  Config
//
//  Created by 영준 이 on 3/9/25.
//

import ProjectDescription

fileprivate let projects: [Path] = ["App", "ThirdParty", "DynamicThirdParty"]
    .map{ "Projects/\($0)" }

let workspace = Workspace(name: "sendadv", projects: projects)
