// swift-tools-version: 6.2

import PackageDescription

extension String {
    static let rfc8200: Self = "RFC 8200"
}

extension Target.Dependency {
    static var rfc8200: Self { .target(name: .rfc8200) }
    static var rfc4291: Self { .product(name: "RFC 4291", package: "swift-rfc-4291") }
    static var standards: Self { .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions") }
    static var incits41986: Self { .product(name: "ASCII", package: "swift-ascii") }
}

let package = Package(
    name: "swift-rfc-8200",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(name: .rfc8200, targets: [.rfc8200])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-rfc-4291.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", from: "0.0.1"),
        .package(url: "https://github.com/swift-foundations/swift-ascii.git", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: .rfc8200,
            dependencies: [
                .rfc4291,
                .standards,
                .incits41986,
            ]
        ),
        .testTarget(
            name: .rfc8200.tests,
            dependencies: [
                .rfc8200
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings =
        existing + [
            .enableUpcomingFeature("ExistentialAny"),
            .enableUpcomingFeature("InternalImportsByDefault"),
            .enableUpcomingFeature("MemberImportVisibility"),
        ]
}
