// swift-tools-version: 6.1

import PackageDescription

let package = Package(
  name: "swift-snapshot-testing-macros-sample",
  platforms: [
    // Deliberately the library's own declared minimums. If the library ever raises
    // one without saying so, this package stops resolving and CI says why.
    .macOS(.v15),
    .iOS(.v15),
  ],
  dependencies: [
    // TODO: pin to a version once v3 is tagged. It is on a branch because the naming
    // and platform work this package exercises has not shipped yet.
    .package(url: "https://github.com/adammcarter/swift-snapshot-testing-macros", branch: "snapshot-helpers")
  ],
  targets: [
    .target(name: "SampleViews"),
    .testTarget(
      name: "SampleConsumerTests",
      dependencies: [
        "SampleViews",
        .product(name: "SnapshotTestingMacros", package: "swift-snapshot-testing-macros"),
      ]
    ),
  ]
)
