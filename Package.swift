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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/5.3.0/openwrapsdk-5.3.0.zip",
            checksum: "243f8c4fe795f092fe23a9f310043ea60ab2c8a0651f3f6525950528d4ebff41"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.6.3/omsdk-pubmatic-1.6.3.zip",
            checksum: "4c80753222f11d508726ccf577cc891da66fbd8974ef970977dd6fcffc6c7022"
        )
    ]
)
