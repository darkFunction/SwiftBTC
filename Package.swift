// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftBTC",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        //.package(url: "https://github.com/Boilertalk/secp256k1.swift.git")
        .package(url: "https://github.com/darkFunction/Clibsecp256k1", .branch("master")),
        .package(url: "https://github.com/IBM-Swift/CommonCrypto", .exact("1.0.0")),
        .package(url: "https://github.com/darkFunction/SwiftRIPEMD160", .branch("master")),
		.package(url: "https://github.com/attaswift/BigInt.git", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "SwiftBTCLib",
            dependencies: ["SwiftRIPEMD160", "BigInt"],
			path: "Sources/SwiftBTCLib"
		),
        .target(
            name: "SwiftBTCApp",
            dependencies: ["SwiftBTCLib"],
			path: "Sources/SwiftBTCApp"
		),
		.testTarget(
			name: "SwiftBTCTests",
			dependencies: ["SwiftBTCLib"],
			path: "Tests"
		)
    ]
)
