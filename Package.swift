// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "swift-ac-memoize",
  platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "AcMemoize",
      targets: ["AcMemoize"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
//    .package(url: "https://github.com/narumij/swift-ac-collections.git", from: "0.1.2"),
    .package(url: "https://github.com/narumij/swift-ac-collections.git",
             revision: "f6a32709a32f38eefd20261409b02d01b02eb200")
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    // Macro implementation that performs the source transformation of a macro.
    .macro(
      name: "swift-ac-memoizeMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),

    // Library that exposes a macro as part of its API, which is used in client programs.
    .target(
      name: "AcMemoize",
      dependencies: [
        "swift-ac-memoizeMacros",
        .product(name: "AcCollections", package: "swift-ac-collections"),
      ],
      path: "Sources/swift-ac-memoize/"
    ),

    // A client of the library, which is able to use the macro in its own code.
    .executableTarget(name: "swift-ac-memoizeClient", dependencies: ["AcMemoize"]),

    // A test target used to develop the macro implementation.
    .testTarget(
      name: "swift-ac-memoizeTests",
      dependencies: [
        "swift-ac-memoizeMacros",
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
    
    .testTarget(name: "tests", dependencies: ["AcMemoize"]),
  ]
)
