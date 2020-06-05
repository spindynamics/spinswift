# SpinSwift
SpinSwift is an open source software simulation package for the simulation of magnetic materials.
The aim of SpinSwift is to provide an atomistic code written in [swift](https://swift.org). 
The presented code is an interesting starting point for the development of novel algorithms.

## Getting SpinSwift
SpinSwift is available from major git platforms.
A comprehensive overview of the software features and example input files have to be provided.

## Building SpinSwift
| | **Architecture** | **Master** |
|---|:---:|:---:|
| **macOS**        | x86_64 |![SpinSwift](https://github.com/araven/spinswift/workflows/SwiftOnMac/badge.svg)|
| **Ubuntu 18.04** | x86_64 |![SpinSwift](https://github.com/araven/spinswift/workflows/SwiftOnLinux/badge.svg)|

You have to use the new Swift support in [CMake](https://cmake.org) to build SpinSwift using modern CMake techniques with the [ninja](https://ninja-build.org) generator.

if `swiftc` is not in your path, you will need to add `-DCMAKE_Swift_COMPILER=` with the path to swiftc.

```sh
cmake -G Ninja -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBUILD_TESTING=YES
cd build
ninja
ninja test
```

This invocation builds the project in release mode with debug information.
This enables optimized builds with debug information.
Additionally, the standard CMake option `BUILD_TESTING` is used to enable tests.
This builds tests and is used in the `SpinSwiftCore` library to enable testable exports.

## What is supported

This project builds on Linux and macOS.

- `CMAKE_BUILD_TYPE`
  * `Debug` (no optimizations, debug info)
  * `Release` (all optimizations, no debug info)
  * `RelWithDebInfo` (all optimizations, debug info)
  * `MinSizeRel` (optimized for size)
  
## Contributing

[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-v2.0%20adopted-ff69b4.svg)](code_of_conduct.md)
