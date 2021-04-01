// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "Entita2",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "Entita2", targets: ["Entita2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/kirilltitov/MessagePack.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(
            name: "Entita2",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "MessagePack",
            ]
        ),
        .testTarget(name: "Entita2Tests", dependencies: ["Entita2"]),
    ]
)
