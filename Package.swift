// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "RxFlow",
    platforms: [
        .iOS(.v9), .tvOS(.v9), .macOS(.v10_11)
    ],
    products: [
        .library(name: "RxFlow", targets: ["RxFlow"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.0.0")),
    ],
    targets: [
        .target(name: "RxFlow", dependencies: ["RxSwift", "RxCocoa"], path: "RxFlow"),
        .testTarget(name: "RxFlowTests", dependencies: ["RxFlow", "RxBlocking", "RxTest"], path: "RxFlowTests"),
    ],
    swiftLanguageVersions: [.v5]
)
