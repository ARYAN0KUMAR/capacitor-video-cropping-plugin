// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "VideoCropperProcessor",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "VideoCropperProcessor",
            targets: ["VideoCropperPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", branch: "main")
    ],
    targets: [
        .target(
            name: "VideoCropperPlugin",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/VideoCropperPlugin"),
        .testTarget(
            name: "VideoCropperPluginTests",
            dependencies: ["VideoCropperPlugin"],
            path: "ios/Tests/VideoCropperPluginTests")
    ]
)