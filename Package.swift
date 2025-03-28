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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.5.0/openwrapsdk-4.5.0.zip",
            checksum: "215b286e96011354515a9c10d775401ba9a5683b569fddaed7cd6982ae35943e"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.2/omsdk-pubmatic-1.5.2.zip",
            checksum: "59e332460546b1e26a8d6a8f4c82f14bde2f618e44d5662c19facdcbec7b1e77"
        )
    ]
)
