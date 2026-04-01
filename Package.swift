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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/5.0.1/openwrapsdk-5.0.1.zip",
            checksum: "7f4e07a3d53c34c5d9cf67ecc890bf422aa79e891b4de1dd8109236212238ada"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.6.1/omsdk-pubmatic-1.6.1.zip",
            checksum: "93cee58ddfcf161fba486f0e967c413f079df04f5b6b46106d240b2d58269959"
        )
    ]
)
