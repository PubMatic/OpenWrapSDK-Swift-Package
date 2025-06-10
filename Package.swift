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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.7.0/openwrapsdk-4.7.0.zip",
            checksum: "e7131fbab2b531e4c49dc3819cb6d8b65e1dffe9d12398b9cf4dcd03173a7a03"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.2/omsdk-pubmatic-1.5.2.zip",
            checksum: "59e332460546b1e26a8d6a8f4c82f14bde2f618e44d5662c19facdcbec7b1e77"
        )
    ]
)
