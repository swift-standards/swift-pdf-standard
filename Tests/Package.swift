// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "testing",
    platforms: [
        .macOS(.v26),
    ],
    dependencies: [
        .package(path: ".."),
        .package(path: "../../../swift-foundations/swift-testing"),
        .package(path: "../../../swift-foundations/swift-tests"),
        .package(path: "../../../swift-primitives/swift-test-primitives"),
    ],
    targets: [
        .target(
            name: "PDF Standard Test Support",
            dependencies: [
                .product(name: "PDF Standard", package: "swift-pdf-standard"),
                .product(name: "Test Snapshot Primitives", package: "swift-test-primitives"),
                .product(name: "Test Primitives Test Support", package: "swift-test-primitives"),
            ],
            path: "Support"
        ),
        .testTarget(
            name: "PDF Standard Snapshot Tests",
            dependencies: [
                .product(name: "PDF Standard", package: "swift-pdf-standard"),
                "PDF Standard Test Support",
                .product(name: "Testing", package: "swift-testing"),
                .product(name: "Tests Inline Snapshot", package: "swift-tests"),
            ],
            path: "PDF Standard Snapshot Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
