// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.import PackageDescription

import PackageDescription

let package: Package = Package(
  name: "Examples",
  platforms: [
    .macOS(.v26),
    .custom("Debian", versionString: "13"),
  ],
  products: [
    .executable(
      name: "SimpleTest",
      targets: ["SimpleTest"]),
    .executable(
      name: "CurieTemperatureNi",
      targets: ["CurieTemperatureNi"]),
    .executable(
      name: "sLLG",
      targets: ["sLLG"]),
  ],
  dependencies: [
    .package(url: "https://github.com/pvieito/PythonKit.git", from: "0.5.1"),
    .package(url: "https://github.com/apple/swift-log", from: "1.9.0"),
    .package(name: "Spinswift", path: "../"),
    //.package(url: "https://github.com/pthibaud/spinswift.git", branch: "refactor")
  ],
  targets: [
    .executableTarget(
      name: "CurieTemperatureNi",
      dependencies: ["PythonKit", "Spinswift", .product(name: "Logging", package: "swift-log")],
      path: "CurieTemperatureNi",
      resources: [.process("Ni.cif")],
    ),
    .executableTarget(
      name: "sLLG",
      dependencies: ["PythonKit", "Spinswift", .product(name: "Logging", package: "swift-log")],
      path: "sLLG",
      resources: [.process("Ni.cif")],
    ),
    .executableTarget(
      name: "SimpleTest",
      dependencies: ["PythonKit", "Spinswift", .product(name: "Logging", package: "swift-log")],
      path: "SimpleTest",
      resources: [.process("Ni.cif")],
    )
  ]
)
