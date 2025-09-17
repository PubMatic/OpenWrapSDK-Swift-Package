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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.9.0/openwrapsdk-4.9.0.zip",
            checksum: "c8228c39efbab13a25239989ac7cba7eec8699f3a5fe07c611706c905d98930d"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.6/omsdk-pubmatic-1.5.6.zip",
            checksum: "ee02082511e0af80cf9e14e682511edecdb641cd59f5d1a7e7311b527dadd849"
        )
    ]
)
