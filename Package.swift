// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = Package(
  name: "Spinswift",
  platforms: [
    .macOS(.v26),
    .custom("Debian", versionString: "12"),
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Spinswift",
            targets: ["Spinswift"]
        ),
  ],
  dependencies: [
    .package(url: "https://github.com/pvieito/PythonKit.git", from: "0.5.1"),
    .package(url: "https://github.com/swiftlang/swift-testing.git", from: "6.3.1"),
    .package(url: "https://github.com/swiftlang/swift-format.git", branch: "main"),
    .package(url: "https://github.com/apple/swift-log.git", branch: "main"),
  ],
  targets: [
    .target(
      name: "Spinswift",
      dependencies: [
        "CGSL",
        "PythonKit",
        .product(name: "Logging", package: "swift-log"),
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "SpinswiftTests",
      dependencies: [
        "Spinswift",
        .product(name: "Testing", package: "swift-testing"),
      ]
    ),
    .systemLibrary(
      name: "CGSL",
      pkgConfig: "gsl",
      providers: [
        .brew(["gsl"]),
        .apt(["libgsl-dev"]),
      ]
    ),
  ]
)
