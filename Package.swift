// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxState",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "RxState",
            targets: ["RxState"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/ReactiveX/RxSwift.git", from: "5.1.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "RxState",
            dependencies: ["RxSwift", .product(name: "RxCocoa", package: "RxSwift")],
            path: "RxState/"),
        .testTarget(
            name: "RxStateTests",
            dependencies: ["RxState", .product(name: "RxTest", package: "RxSwift"), .product(name: "RxBlocking", package: "RxSwift")],
            path: "RxStateTests/"),
    ],
    swiftLanguageVersions: [.v5]
)


