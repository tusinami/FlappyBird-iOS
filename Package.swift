// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlappyBird",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "FlappyBird", targets: ["FlappyBird"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "FlappyBird",
            dependencies: [],
            path: "Sources/FlappyBird"
        )
    ]
)
