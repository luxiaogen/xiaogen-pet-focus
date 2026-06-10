// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FocusPet",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "FocusPet", targets: ["FocusPet"])
    ],
    targets: [
        .executableTarget(
            name: "FocusPet",
            path: "Sources/FocusPet",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
