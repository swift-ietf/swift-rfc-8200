# swift-rfc-8200

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The IPv6 header and extension-header format of RFC 8200.

## Standard Reference

- **RFC**: 8200
- **Title**: Internet Protocol, Version 6 (IPv6) Specification

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-8200.git", from: "0.0.1")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 8200", package: "swift-rfc-8200")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
