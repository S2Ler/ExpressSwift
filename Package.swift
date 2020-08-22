// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "ExpressSwift",
  products: [
    .library(name: "ExpressSwift", targets: ["ExpressSwift"]),
    .executable(name: "Example", targets: ["Example"]),
    .executable(name: "HttpsExample", targets: ["HttpsExample"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from: "2.21.0")),
    .package(url: "https://github.com/apple/swift-log.git", .upToNextMajor(from: "1.4.0")),
    .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMajor(from: "2.9.0")),
  ],
  targets: [
    .target(name: "ExpressSwift",
            dependencies: [
              .product(name: "NIOSSL", package: "swift-nio-ssl"),
              .product(name: "NIO", package: "swift-nio"),
              .product(name: "NIOHTTP1", package: "swift-nio"),
              .product(name: "Logging", package: "swift-log"),
            ]),
    .target(name: "Example",
            dependencies: [
              "ExpressSwift",
            ]),
    .target(name: "HttpsExample",
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
