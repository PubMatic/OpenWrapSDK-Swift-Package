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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.8.1/openwrapsdk-4.8.1.zip",
            checksum: "fc2c727b5f3e346dc609785db0bb8758766c94e8f7149a350f9d03ac4c1e6de6"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.4-1/omsdk-pubmatic-1.5.4-1.zip",
            checksum: "4f77aec44b56481cb4a03498e1f7e2649bb2c87ba91b6a7413db1c7859795010"
        )
    ]
)
