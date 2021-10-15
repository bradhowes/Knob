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
    dependencies: [
      .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
    ],
    targets: [
      .target(
            name: "Knob",
            dependencies: []),
        .testTarget(
            name: "KnobTests",
            dependencies: [
              "Knob",
              "SnapshotTesting"
            ]
        ),
    ]
)
