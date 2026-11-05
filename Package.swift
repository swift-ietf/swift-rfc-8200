// swift-tools-version: 6.4

import PackageDescription

extension String {
    static let rfc8200: Self = "RFC 8200"
}

extension Target.Dependency {
    static var rfc8200: Self { .target(name: .rfc8200) }
    static var rfc4291: Self { .product(name: "RFC 4291", package: "swift-rfc-4291") }
    static var rfc5952: Self { .product(name: "RFC 5952", package: "swift-rfc-5952") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var incits41986: Self { .product(name: "ASCII", package: "swift-ascii") }
    static var binary: Self { .product(name: "Binary", package: "swift-binary") }
    static var byte: Self { .product(name: "Byte", package: "swift-byte") }
}

let package = Package(
    name: "swift-rfc-8200",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27)
    ],
    products: [
        .library(name: "RFC 8200", targets: ["RFC 8200"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-4291.git", branch: "main", traits: ["Coder"]),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5952.git", branch: "main", traits: ["Coder"]),
        .package(url: "https://github.com/swift-atoms/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-binary.git", branch: "main", traits: ["Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RFC 8200",
            dependencies: [
                .rfc4291,
                .rfc5952,
                .standards,
                .incits41986,
                .binary,
                .byte
            ]
        ),
        .testTarget(
            name: "RFC 8200 Tests",
            dependencies: [
                "RFC 8200",
            ]
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
