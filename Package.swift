// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "KnobPackage",
  platforms: [.macOS(.v10_15), .iOS(.v12)],
  products: [
    .library(name: "Knob", targets: ["Knob"]),
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
      ]
    ),
    .testTarget(
      name: "KnobTests",
      dependencies: [
        "Knob",
        .productItem(name: "SnapshotTesting", package: "swift-snapshot-testing", condition: .none)
      ],
      exclude: ["__Snapshots__/"]
    ),
  ]
)
