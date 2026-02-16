// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Safari",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Safari",
            targets: ["Safari"]
        )
    ],
    targets: [
        .target(
            name: "Safari",
            dependencies: []
        )
    ]
)
