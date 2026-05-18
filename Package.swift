// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftKanbanLearning",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "KanbanCore", targets: ["KanbanCore"]),
        .executable(name: "kanban", targets: ["kanban"]),
        .executable(name: "KanbanBoardApp", targets: ["KanbanBoardApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0")
    ],
    targets: [
        .target(name: "KanbanCore"),
        .executableTarget(
            name: "kanban",
            dependencies: [
                "KanbanCore",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .executableTarget(
            name: "KanbanBoardApp",
            dependencies: ["KanbanCore"]
        ),
        .testTarget(name: "KanbanCoreTests", dependencies: ["KanbanCore"])
    ]
)
