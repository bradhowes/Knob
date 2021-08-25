// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Knob",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Knob",
            targets: ["Knob"]),
    ],
    targets: [
        .target(
            name: "Knob",
            dependencies: []),
        .testTarget(
            name: "KnobTests",
            dependencies: ["Knob"]),
    ]
)
