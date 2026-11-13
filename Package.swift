// swift-tools-version: 6.2

import PackageDescription

let package = Package(
  name: "swift-ac-memoize",
  platforms: [.macOS(.v15)],
  products: [
    .library(
      name: "AcMemoize",
      targets: ["AcMemoize"]
    )
  ],
  traits: [
    .trait(
      name: "ENABLE_EXPERIMENTAL_LRU",
      description: "Connect the experimental noncopyable LRUCache of swift-ac-collections."
    ),
    .trait(
      name: "ENABLE_OPTIONAL_ELEMENT_BUFFER",
      description: "Connect OptionalElementBuffer of swift-ac-collections."
    ),
  ],
  dependencies: [
    .package(path: "/Users/narumij/Documents/GitHub/Memoization"),
    .package(
      path: "/Users/narumij/Documents/GitHub/swift-ac-collections",
      traits: [
        .trait(name: "ENABLE_EXPERIMENTAL_LRU", condition: .when(traits: ["ENABLE_EXPERIMENTAL_LRU"])),
        .trait(
          name: "ENABLE_OPTIONAL_ELEMENT_BUFFER", condition: .when(traits: ["ENABLE_OPTIONAL_ELEMENT_BUFFER"])),
      ]),
  ],
  targets: [
    .target(
      name: "AcMemoize",
      dependencies: [
        .product(name: "Memoization", package: "Memoization"),
        .product(name: "AcCollections", package: "swift-ac-collections"),
      ],
      swiftSettings: [
        .define("ENABLE_EXPERIMENTAL_LRU", .when(traits: ["ENABLE_EXPERIMENTAL_LRU"])),
        .define("ENABLE_OPTIONAL_ELEMENT_BUFFER", .when(traits: ["ENABLE_OPTIONAL_ELEMENT_BUFFER"])),
      ]
    ),
    .testTarget(
      name: "AcMemoizeTests",
      dependencies: ["AcMemoize"],
      swiftSettings: [
        .define("ENABLE_EXPERIMENTAL_LRU", .when(traits: ["ENABLE_EXPERIMENTAL_LRU"])),
        .define("ENABLE_OPTIONAL_ELEMENT_BUFFER", .when(traits: ["ENABLE_OPTIONAL_ELEMENT_BUFFER"])),
      ]
    ),
  ]
)
