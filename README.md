# PDF Standard

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A convenience namespace for the PDF document model in Swift — aliases the ISO 32000 definitions under a single `PDF` surface.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-pdf-standard.git", branch: "main")
]
```

Add the product to your target:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "PDF Standard", package: "swift-pdf-standard")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
