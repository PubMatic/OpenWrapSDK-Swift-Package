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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/5.5.0/openwrapsdk-5.5.0.zip",
            checksum: "5497d822624d7c91e4f9df1e268157427d17e85cf85e494c8413b9082fc85922"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos-gradle/ios/swift-pkg-manager/omsdk-pubmatic/1.6.3/omsdk-pubmatic-1.6.3.zip",
            checksum: "2775b92d00d3ab58a10f805d3226fadb41ab5af1462e69dd16196a863a370bd8"
        )
    ]
)
