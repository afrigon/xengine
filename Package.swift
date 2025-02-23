// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "XEngine",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2)
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
