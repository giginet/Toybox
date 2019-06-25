// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toybox",
    platforms: [.macOS(.v10_10)],
    products: [
        .executable(
            name: "toybox",
            targets: ["toybox"]),
        .library(
            name: "ToyboxKit",
            targets: ["ToyboxKit"]),
    ],
    dependencies: [
        .package(url: "https://github.com/drmohundro/SWXMLHash.git", from: "4.9.0"),
        .package(url: "https://github.com/Carthage/Commandant.git", from: "0.17.0"),
    ],
    targets: [
        .target(
            name: "toybox",
            dependencies: [
                "ToyboxKit",
                "Commandant",
            ]),
        .target(
            name: "ToyboxKit",
            dependencies: [
                "Commandant",
                "SWXMLHash",
            ]),
        .testTarget(
            name: "ToyboxKitTests",
            dependencies: ["toybox"]),
    ],
    swiftLanguageVersions: [.v5]
)
