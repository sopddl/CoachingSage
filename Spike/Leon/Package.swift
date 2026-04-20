// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LeonSpike",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "LeonSpike",
            path: "Sources/LeonSpike"
        )
    ]
)
