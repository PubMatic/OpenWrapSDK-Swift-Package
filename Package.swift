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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.8.0/openwrapsdk-4.8.0.zip",
            checksum: "32b4806aa0b8bc998b5f482d8836e3dae8aed9885a05e4fc0d225f34ccdc25f1"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.4/omsdk-pubmatic-1.5.4.zip",
            checksum: "c70a36f38ceb6ed7e7a00a2ccb4a4a86137b984d6d6ad36aae50f46106cc2825"
        )
    ]
)
