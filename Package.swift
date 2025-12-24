// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "OpenWrapSDK",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "OpenWrapSDK", targets: ["OpenWrapSDK", "OMSDK_Pubmatic"])
    ],
    targets: [
        .binaryTarget(
            name: "OpenWrapSDK",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.11.0/openwrapsdk-4.11.0.zip",
            checksum: "598d0839f9e48f27f75f7f349d07556bcf3c090fa8bfaa40dbbd8a55aa188b13"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.6.1/omsdk-pubmatic-1.6.1.zip",
            checksum: "93cee58ddfcf161fba486f0e967c413f079df04f5b6b46106d240b2d58269959"
        )
    ]
)
