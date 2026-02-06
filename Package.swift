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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.12.0/openwrapsdk-4.12.0.zip",
            checksum: "dd633b8fe16d232428a526fd98fd512da1a68383ab1252a1f01bd345e8acb10c"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.6.1/omsdk-pubmatic-1.6.1.zip",
            checksum: "93cee58ddfcf161fba486f0e967c413f079df04f5b6b46106d240b2d58269959"
        )
    ]
)
