// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-email",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Email",
            targets: ["Email"]
        ),
        .library(
            name: "Email Received",
            targets: ["Email Received"]
        ),
    ],
    traits: [
        .trait(
            name: "Translating",
            description: "Include TranslatedString integration for internationalization support"
        )
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-email-standard", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5322.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-2045.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-2046.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-2046-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-2047.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-2183.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-2231.git", branch: "main"),
        .package(url: "https://github.com/swift-whatwg/swift-whatwg-encoding.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-html.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-dependencies.git", branch: "main"),
        // PARKED with EmailMarkdown.swift (coenttb-ectomy 2026-07-12) — sole consumer:
        // .package(url: "https://github.com/swiftlang/swift-markdown", from: "0.4.0"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.2"),
        .package(url: "https://github.com/swift-compositions/swift-translating.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-translating-dependencies.git", branch: "main")
    ],
    targets: [
        .target(
            name: "Email",
            dependencies: [
                .product(name: "Email Standard", package: "swift-email-standard"),
                .product(name: "RFC 5322", package: "swift-rfc-5322"),
                .product(name: "HTML", package: "swift-html"),
                // HANDED OVER (E-1 R-3, 2026-07-13): the parked pf-html-era surface
                // (EmailDocument/EmailMarkdown/BaseStyles/Email+HTML + tests) now lives in
                // swift-email-html — live AppleMail .eml surface plus a Parked/ staging of
                // the pf-era files; their restore stays gated on the OPEN HTML-email story
                // (see swift-email-html Parked/Email/README.md).
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(
                    name: "Translating",
                    package: "swift-translating",
                    condition: .when(traits: ["Translating"])
                ),
                .product(
                    name: "Translating Dependencies",
                    package: "swift-translating-dependencies",
                    condition: .when(traits: ["Translating"])
                )
            ],
            swiftSettings: [
                .define("TRANSLATING", .when(traits: ["Translating"]))
            ]
        ),
        .testTarget(
            name: "Email Tests",
            dependencies: ["Email"]
        ),
        .target(
            name: "Email Received",
            dependencies: [
                .product(name: "Email Standard", package: "swift-email-standard"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "RFC 2045", package: "swift-rfc-2045"),
                .product(name: "RFC 2046", package: "swift-rfc-2046"),
                .product(name: "RFC 2046 Coder", package: "swift-rfc-2046-coder"),
                .product(name: "RFC 2047", package: "swift-rfc-2047"),
                .product(name: "RFC 2183", package: "swift-rfc-2183"),
                .product(name: "RFC 2231", package: "swift-rfc-2231"),
                .product(name: "WHATWG Encoding", package: "swift-whatwg-encoding"),
            ]
        ),
        .testTarget(
            name: "Email Received Tests",
            dependencies: [
                .target(name: "Email Received"),
                .product(name: "Email Standard", package: "swift-email-standard"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "RFC 2045", package: "swift-rfc-2045"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
