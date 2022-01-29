// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "KnobPackage",
  platforms: [.macOS(.v10_15), .iOS(.v12)],
  products: [
    .library(name: "Knob-iOS", targets: ["Knob_iOS"]),
    .library(name: "Knob-macOS", targets: ["Knob_macOS"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
  ],
  targets: [
    .target(
      name: "Knob_iOS",
      dependencies: [],
      swiftSettings: [
        .define("APPLICATION_EXTENSION_API_ONLY")
      ]
    ),
    .target(
      name: "Knob_macOS",
      dependencies: [],
      swiftSettings: [
        .define("APPLICATION_EXTENSION_API_ONLY")
      ]
    ),
    .testTarget(
      name: "Knob_iOSTests",
      dependencies: [
        "Knob_iOS",
        .productItem(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .none)
      ],
      exclude: ["__Snapshots__"]
    ),
    .testTarget(
      name: "Knob_macOSTests",
      dependencies: [
        "Knob_macOS",
        .productItem(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .none)
      ],
      exclude: ["__Snapshots__"]
    ),
  ]
)
