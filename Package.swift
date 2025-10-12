// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TechTive",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "TechTive",
            targets: ["TechTive"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "TechTive",
            dependencies: [])
    ])
