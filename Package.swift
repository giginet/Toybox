// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Toybox",
    products: [
        .executable(
            name: "toybox",
            targets: ["Toybox"]),
        .library(
            name: "ToyboxKit",
            targets: ["ToyboxKit"]),
    ],
    dependencies: [
        .package(url: "git@github.com:drmohundro/SWXMLHash.git", from: "4.2.0"),
        .package(url: "git@github.com:Carthage/Commandant.git", from: "0.12.0"),
    ],
    targets: [
        .target(
            name: "Toybox",
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
            dependencies: ["Toybox"]),
    ]
)
