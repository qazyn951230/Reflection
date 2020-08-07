// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reflection",
    products: [
        .library(
            name: "Reflection",
            targets: ["Reflection"]),
        .executable(
            name: "Demo",
            targets: ["Demo"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Reflection",
            dependencies: []),
        .testTarget(
            name: "ReflectionTests",
            dependencies: ["Reflection"]),
        .target(
            name: "Demo",
            dependencies: ["Reflection"]),
    ],
    cxxLanguageStandard: .cxx1z
)
