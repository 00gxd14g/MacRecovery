// swift-tools-version: 5.5
import PackageDescription

let package = Package(
    name: "MacRecovery",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "MacRecovery", targets: ["MacRecovery"])
    ],
    targets: [
        .executableTarget(
            name: "MacRecovery",
            path: "Sources/MacRecovery"
        ),
        .testTarget(
            name: "MacRecoveryTests",
            dependencies: ["MacRecovery"]
        )
    ]
)
