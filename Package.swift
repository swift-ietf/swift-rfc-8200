// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rfc8200: Self = "RFC 8200"
}

extension Target.Dependency {
    static var rfc8200: Self { .target(name: .rfc8200) }
    static var rfc4291: Self { .product(name: "RFC 4291", package: "swift-rfc-4291") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var incits41986: Self { .product(name: "ASCII Primitives", package: "swift-ascii-primitives") }
}

let package = Package(
    name: "swift-rfc-8200",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(name: "RFC 8200", targets: ["RFC 8200"])
    ],
    dependencies: [
        .package(path: "../swift-rfc-4291"),
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-ascii-primitives")
    ],
    targets: [
        .target(
            name: "RFC 8200",
            dependencies: [
                .rfc4291,
                .standards,
                .incits41986
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
