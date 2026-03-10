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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/5.0.0/openwrapsdk-5.0.0.zip",
            checksum: "c54c94152d6238f4e14ad761205c4091d9668fe43c04312b59b1aefaf2a096f3"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.6.1/omsdk-pubmatic-1.6.1.zip",
            checksum: "93cee58ddfcf161fba486f0e967c413f079df04f5b6b46106d240b2d58269959"
        )
    ]
)
