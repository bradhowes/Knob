// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "KnobPackage",
  platforms: [.macOS(.v10_15), .iOS(.v12)],
  products: [
    .library(name: "Knob-iOS", targets: ["Knob-iOS"]),
    .library(name: "Knob-macOS", targets: ["Knob-macOS"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.11.0"),
  ],
  targets: [
    .target(
      name: "Knob-iOS",
      dependencies: [],
      swiftSettings: [
        .define("APPLICATION_EXTENSION_API_ONLY")
      ]
    ),
    .target(
      name: "Knob-macOS",
      dependencies: [],
      swiftSettings: [
        .define("APPLICATION_EXTENSION_API_ONLY")
      ]
    ),
    .testTarget(
      name: "Knob-iOSTests",
      dependencies: [
        "Knob-iOS",
        .productItem(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .none)
      ],
      exclude: ["__Snapshots__"]
    ),
    .testTarget(
      name: "Knob-macOSTests",
      dependencies: [
        "Knob-macOS",
        .productItem(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .none)
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
