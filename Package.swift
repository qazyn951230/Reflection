// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Reflection",
    platforms: [.macOS("10.15")],
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
            name: "CReflection",
            dependencies: [],
            cxxSettings: [
                .headerSearchPath("External/swift/include"),
                .headerSearchPath("External/llvm/include"),
                .headerSearchPath("External/release/swift/include"),
                .headerSearchPath("External/release/llvm/include")
            ],
            linkerSettings: [
                .linkedLibrary("swiftDemangle")
            ]
        ),
        .target(
            name: "Reflection",
            dependencies: ["CReflection"],
            swiftSettings: [.define("SWIFT_OBJC_INTEROP")]),
        .testTarget(
            name: "ReflectionTests",
            dependencies: ["Reflection"]),
        .target(
            name: "Demo",
            dependencies: ["Reflection"]),
    ],
    cxxLanguageStandard: .cxx1z
)
