// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "Concurrency",
  platforms: [.iOS(.v12)],
  products: [
    .library(name: "Concurrency", targets: ["Concurrency"]),
  ],
  dependencies: [
  ],
  targets: [
    .target(name: "Concurrency", dependencies: []),
    .testTarget(name: "ConcurrencyTests", dependencies: [
      .target(name: "Concurrency"),
    ]),
  ]
)
