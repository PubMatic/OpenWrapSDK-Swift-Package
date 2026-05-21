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
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/openwrapsdk/5.1.1/openwrapsdk-5.1.1.zip",
            checksum: "e525cd238e21673aaefbc137784ae4a4293d2139c759bbb7da44480ce63d6676"
        ),
        .binaryTarget(
            name: "OMSDK_Pubmatic",
            url: "https://repo.pubmatic.com/artifactory/public-repos/ios/swift-pkg-manager/omsdk-pubmatic/1.6.3/omsdk-pubmatic-1.6.3.zip",
            checksum: "4c80753222f11d508726ccf577cc891da66fbd8974ef970977dd6fcffc6c7022"
        )
    ]
)
