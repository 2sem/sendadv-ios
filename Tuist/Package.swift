// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import struct ProjectDescription.PackageSettings

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,]
        productTypes: [:]
    )
#endif

let package = Package(
    name: "sendadv",
    dependencies: [
        // Migrating from Project.swift `packages:` one package at a time;
        // consumed via `.external(name:)`.
        .package(url: "https://github.com/2sem/GADManager", from: "1.5.0"),
    ]
)
