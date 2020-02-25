// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Entita2",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(name: "Entita2", targets: ["Entita2"]),
    ],
    dependencies: [
        .package(url: "git@github.com:kirilltitov/LGNKit-Swift.git", .branch("master")),
        .package(url: "https://github.com/kirilltitov/MessagePack.git", .upToNextMajor(from: "2.0.0")),
    ],
    targets: [
        .target(name: "Entita2", dependencies: ["LGNCore", "MessagePack"]),
        .testTarget(name: "Entita2Tests", dependencies: ["Entita2"]),
    ]
)
