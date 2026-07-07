// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Templates",
    platforms: [.macOS(.v13), .iOS(.v17)],
    products: [
        .library(name: "TemplateModel", targets: ["TemplateModel"]),
        .library(name: "TemplateLoader", targets: ["TemplateLoader"]),
        .executable(name: "TemplateValidator", targets: ["TemplateValidator"]),
        .executable(name: "GenerateTemplates", targets: ["GenerateTemplates"]),
        .executable(name: "GenerateSummaries", targets: ["GenerateSummaries"]),
        .executable(name: "ChallengeTemplates", targets: ["ChallengeTemplates"]),
        .executable(name: "ReviseTemplates", targets: ["ReviseTemplates"]),
        .executable(name: "TestAdaptability", targets: ["TestAdaptability"]),
    ],
    targets: [
        .target(
            name: "TemplateModel"
        ),
        .executableTarget(
            name: "TemplateValidator",
            dependencies: ["TemplateModel"]
        ),
        .executableTarget(
            name: "GenerateTemplates",
            dependencies: ["TemplateModel"]
        ),
        .executableTarget(
            name: "GenerateSummaries",
            dependencies: ["TemplateModel"]
        ),
        .executableTarget(
            name: "ChallengeTemplates",
            dependencies: ["TemplateModel"]
        ),
        .executableTarget(
            name: "ReviseTemplates",
            dependencies: ["TemplateModel"]
        ),
        .executableTarget(
            name: "TestAdaptability",
            dependencies: ["TemplateModel"]
        ),
        .target(
            name: "TemplateLoader",
            dependencies: ["TemplateModel"],
            resources: [
                .copy("Resources/Templates"),
                .copy("Resources/template-summaries.json"),
            ]
        ),
        .testTarget(
            name: "TemplateModelTests",
            dependencies: ["TemplateModel"],
            resources: [.process("Fixtures")]
        ),
        .testTarget(
            name: "TemplateLoaderTests",
            dependencies: ["TemplateLoader", "TemplateModel"],
            resources: [.process("Fixtures")]
        ),
    ]
)
