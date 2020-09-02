// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let enableDemangle = true
let demangle = enableDemangle ? "ENABLE_REFLECTION_DEMANGLE" : "DISABLE_REFLECTION_DEMANGLE"
let dependencies: [Target.Dependency] = enableDemangle ? ["CReflection"] : []

let settings: [SwiftSetting] = [
    .define("SWIFT_OBJC_INTEROP"),
    .define(demangle),
    .define("DEBUG_MIRROR")
]

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
                .headerSearchPath("External/release/llvm/include"),
                .unsafeFlags([
                    "-Wno-deprecated-declarations", // for asl_log in Errors.cpp
                    "-Wno-pointer-bool-conversion",
                    "-Wno-tautological-pointer-compare",
                    "-fno-objc-arc"
                ]),
                .define("DEBUG_LOG"),
                .define("DEBUG_MIRROR")
            ],
            linkerSettings: [
                .linkedLibrary("swiftCore"),
                .linkedLibrary("swiftDemangle"),
                .linkedLibrary("objc")
            ]
        ),
        .target(
            name: "Reflection",
            dependencies: dependencies,
            swiftSettings: settings
        ),
        .testTarget(
            name: "ReflectionTests",
            dependencies: ["Reflection"]),
        .target(
            name: "Demo",
            dependencies: ["Reflection", "CReflection"]),
    ],
    cxxLanguageStandard: .cxx1z
)
