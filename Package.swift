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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.4/omsdk-pubmatic-1.5.4.zip",
            checksum: "9fa4924b73721127d7f821a65a3bbc36c932817e038a0cf5e99c4d76d728c051"
        )
    ]
)
