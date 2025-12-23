// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ShimmerKit",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ShimmerKit",
            targets: ["ShimmerKit"]
        )
    ],
    targets: [
        .target(
            name: "ShimmerKit",
            dependencies: []
        )
    ]
)
