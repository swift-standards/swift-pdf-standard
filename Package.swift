// swift-tools-version: 6.4

import PackageDescription

// swift-pdf-standard: Unified PDF API with ergonomic coordinate system
let package = Package(
    name: "swift-pdf-standard",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "PDF Standard", targets: ["PDF Standard"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-iso/swift-iso-32000.git", branch: "main")
        // .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.0")
    ],
    targets: [
        .target(
            name: "PDF Standard",
            dependencies: [
                .product(name: "ISO 32000", package: "swift-iso-32000"),
                .product(name: "ISO 32000 Flate", package: "swift-iso-32000"),
            ]
        ),
        .testTarget(
            name: "PDF Standard Tests",
            dependencies: [
                "PDF Standard"
            ],
            path: "Tests/PDF Standard Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
