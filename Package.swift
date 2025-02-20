// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "XEngine",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "XEngineCore", targets: ["XEngineCore"]),
        .library(name: "XEngineMetal", targets: ["XEngineMetal"])
    ],
    targets: [
        .target(
            name: "XEngineCore",
                path: "Sources/Core"
        ),
        .target(
            name: "XEngineMetal",
            dependencies: [
                .target(name: "XEngineCore")
            ],
            path: "Sources/Metal",
            resources: [
                .process("Resources/Shaders")
            ]
        )
    ]
)
