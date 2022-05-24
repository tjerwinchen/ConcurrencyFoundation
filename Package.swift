// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "ConcurrencyFoundation",
  platforms: [.iOS(.v12), .tvOS(.v12), .watchOS(.v5), .macOS(.v10_13)],
  products: [
    .library(name: "ConcurrencyFoundation", targets: ["ConcurrencyFoundation"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-atomics.git", .upToNextMajor(from: "1.0.2")),
  ],
  targets: [
    .target(name: "ConcurrencyFoundation", dependencies: [
      .product(name: "Atomics", package: "swift-atomics"),
    ]),
    .testTarget(name: "ConcurrencyFoundationTests", dependencies: [
      .target(name: "ConcurrencyFoundation"),
    ]),
  ]
)
