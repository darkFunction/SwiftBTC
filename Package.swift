// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBTC",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //.package(url: "https://github.com/Boilertalk/secp256k1.swift.git")
        .package(url: "https://github.com/darkFunction/Clibsecp256k1", .branch("master"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SwiftBTC",
            dependencies: []),
    ]
)
