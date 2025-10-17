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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/4.10.0/openwrapsdk-4.10.0.zip",
            checksum: "ae0499d356f61703aa5ca04e213811d736d6bb4ea5233192fc0ea859ffa96374"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.5.6/omsdk-pubmatic-1.5.6.zip",
            checksum: "ee02082511e0af80cf9e14e682511edecdb641cd59f5d1a7e7311b527dadd849"
        )
    ]
)
