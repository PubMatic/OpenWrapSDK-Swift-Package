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
            checksum: "905f462255d886fa1e1a3fa48527db8ec23b5aca2416a354d85ff54b8be749f9"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.4/omsdk-pubmatic-1.5.4.zip",
            checksum: "c70a36f38ceb6ed7e7a00a2ccb4a4a86137b984d6d6ad36aae50f46106cc2825"
        )
    ]
)
