// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "RxFlow",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "RxFlow", targets: ["RxFlow"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "5.1.1")),
    ],
    targets: [
        .target(name: "RxFlow", dependencies: ["RxSwift", "RxCocoa"], path: "RxFlow"),
        .testTarget(name: "RxFlowTests", dependencies: ["RxFlow", "RxBlocking", "RxTest"], path: "RxFlowTests"),
    ],
    swiftLanguageVersions: [.v5]
)
