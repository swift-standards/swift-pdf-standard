// swift-tools-version: 6.2

import PackageDescription

// swift-pdf-standard: Unified PDF API with ergonomic coordinate system
let package = Package(
    name: "swift-pdf-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: "PDF Standard", targets: ["PDF Standard"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-iso-32000", from: "0.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.18.0"),
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
            name: "PDF Standard".tests,
            dependencies: [
                "PDF Standard",
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
