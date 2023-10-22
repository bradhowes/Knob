// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Knob",
  platforms: [.macOS(.v11), .iOS(.v13)],
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
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .none)
      ],
      exclude: ["__Snapshots__"]
    ),
    .testTarget(
      name: "Knob-macOSTests",
      dependencies: [
        "Knob-macOS",
        .product(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .none)
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
