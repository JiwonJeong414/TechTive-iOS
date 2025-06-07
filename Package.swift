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
            targets: ["TechTive"]),
    ],
    dependencies: [
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "TechTive",
            dependencies: ["Inject"]),
    ]
) 