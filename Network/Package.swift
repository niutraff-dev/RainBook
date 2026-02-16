// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Network",
    platforms: [
        .iOS(.v16),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "Network",
            targets: ["Network"]
        )
    ],
    targets: [
        .target(
            name: "Network",
            dependencies: [],
            path: "Sources/Network"
        ),
        .testTarget(
            name: "NetworkTests",
            dependencies: ["Network"],
            path: "Tests/NetworkTests"
        )
    ]
)
