// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KnobPackage",
  platforms: [
    .macOS(.v10_15),
    .iOS(.v12)
  ],
  products: [
    .library(
      name: "Knob",
      type: .dynamic,
      targets: ["Knob"]),
    .library(
      name: "Knob-Static",
      type: .static,
      targets: ["Knob"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
  ],
  targets: [
    .target(
      name: "Knob",
      dependencies: [],
      swiftSettings: [
        .define("APPLICATION_EXTENSION_API_ONLY")
      ]),
    .testTarget(
      name: "KnobTests",
      dependencies: [
        "Knob",
        "SnapshotTesting"
      ],
      exclude: ["__Snapshots__/"]
    ),
  ]
)
