// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package: Package = Package(
    name: "spinswift",
    platforms: [.macOS(.v10_15)],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        // .package(url: "https://github.com/apple/swift-docc-plugin", branch: "main"),
        .package(url: "https://github.com/apple/swift-format", from: "508.0.1"),
        // .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-cmark", branch: "gfm"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "spinswift",
            dependencies: ["CGSL"],
            exclude: []),
        .testTarget(
            name: "spinswiftTests",
            dependencies: ["spinswift"]),
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
