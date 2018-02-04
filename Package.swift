// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "grift",
    products: [
        .executable(name: "grift", targets: ["grift",  "GriftKit"]),
        .library(name: "GriftKit", targets: ["GriftKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/davecom/SwiftGraph.git", from: "1.5.1"),
        .package(url: "https://github.com/jpsim/SourceKitten.git", from: "0.19.1"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.13.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "grift",
            dependencies: ["GriftKit", "Commandant"]),
        .target(
            name: "GriftKit",
            dependencies: ["Graphviz", "SwiftGraph", "SourceKittenFramework"]),
        .target(
            name: "Graphviz",
            dependencies: ["SwiftGraph"]),
        .testTarget(
            name: "GriftKitTests",
            dependencies: ["GriftKit"]),
        .testTarget(
            name: "GraphvizTests",
            dependencies: ["Graphviz", "SwiftGraph"]),
    ]
)
