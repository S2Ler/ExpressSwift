// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "ExpressSwift",
  products: [
    .library(name: "ExpressSwift", targets: ["ExpressSwift"]),
    .executable(name: "Example", targets: ["Example"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
    .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
  ],
  targets: [
    .target(name: "ExpressSwift",
            dependencies: [
              "NIO",
              "NIOHTTP1",
              "Logging",
            ]),
    .target(name: "Example",
            dependencies: [
              "ExpressSwift",
            ]),
    .testTarget(name: "ExpressSwiftTests",
                dependencies: [
                  "ExpressSwift",
                ]),
  ],
  swiftLanguageVersions: [.v5]
)
