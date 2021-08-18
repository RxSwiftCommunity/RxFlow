// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "RxFlow",
    platforms: [.iOS(.v9)],
    products: [
        .library(name: "RxFlow", targets: ["RxFlow"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.0.0")),
    ],
    targets: [
        .target(
            name: "RxFlow",
            dependencies: [
                "RxSwift",
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "RxFlow",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "RxFlowTests",
            dependencies: [
                "RxFlow",
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift")
            ],
            path: "RxFlowTests",
            exclude: ["Info.plist"]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
