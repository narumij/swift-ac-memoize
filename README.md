# swift-ac-memoize

English | [日本語](README.ja.md)

`swift-ac-memoize` connects the memoization macros of [Memoization][memoization] with the containers of [swift-ac-collections][collections].

[![Swift](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Installation

Add the following to your Package.swift:
```
platforms: [.macOS(.v15)]
```

```
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-memoize", branch: "main"),
],
```

Add the following to your build target:

```
  dependencies: [
    .product(name: "AcMemoize", package: "swift-ac-memoize")
  ]
```

Add the following to your source code:
```
import AcMemoize
```

`AcMemoize` re-exports `Memoization`.

### AtCoder 2025 judge

The previous version for the AtCoder 2025 judge is on the `compatible/AtCoder/2025` branch.

```
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-memoize", branch: "compatible/AtCoder/2025"),
],
```

## Usage

`@Memoize`, `@Memoizable`, and the generated `fooCache<...>` alias work the same as in [Memoization][memoization].

```swift
@Memoize
func tarai(x: Int, y: Int, z: Int) -> Int {
  if x <= y {
    return y
  } else {
    return tarai(
      x: tarai(x: x - 1, y: y, z: z),
      y: tarai(x: y - 1, y: z, z: x),
      z: tarai(x: z - 1, y: x, z: y))
  }
}
print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))") // Output: 20
```

This package makes the containers of swift-ac-collections conform to `MemoCache`.
Pass one to a `cache:` overload to use it as the cache.

## Available caches

### RedBlackTreeDictionary

A red-black tree dictionary. The argument types only need to be `Comparable`.

```swift
@Memoizable
func paths(_ p: Point) -> Int {
  p.x == 0 || p.y == 0 ? 1 : paths(Point(x: p.x - 1, y: p.y)) + paths(Point(x: p.x, y: p.y - 1))
}

var cache = pathsCache<RedBlackTreeDictionary>()
paths(Point(x: 16, y: 16), cache: &cache)
```

### LRUCache

An [LRU (least recently used)](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_Recently_Used_(LRU)) cache that limits how many entries it keeps.
The argument types only need to be `Comparable`. It is a noncopyable type.

```swift
var cache = pathsCache<LRUCache>(maxCount: 64)
paths(Point(x: 16, y: 16), cache: &cache)
```

It is experimental in swift-ac-collections, so its API may change.

### OptionalElementBuffer

An array indexed by `Int` arguments, in one to four dimensions.
Size it to fit the range of the arguments.

```swift
@Memoizable
func fib(_ n: Int) -> Int {
  n < 2 ? n : fib(n - 1) + fib(n - 2)
}

var cache = fibCache<OptionalElementBuffer>(capacity: 91)
fib(90, cache: &cache)
```

```swift
// For @Memoizable func rec(_ i: Int, _ j: Int, _ k: Int) -> Double
var cache = recCache<OptionalElementBuffer3D>(width: 11, height: 11, depth: 11)
```

## Traits

Traits switch the connection of `LRUCache` and `OptionalElementBuffer`. Both are enabled by default.

| Trait | Effect |
| --- | --- |
| `ENABLE_EXPERIMENTAL_LRU` | Connects `LRUCache` |
| `ENABLE_OPTIONAL_ELEMENT_BUFFER` | Connects `OptionalElementBuffer` |

To disable them, choose the traits in your dependency.

```
.package(url: "https://github.com/narumij/swift-ac-memoize", branch: "main", traits: []),
```

## License

This library is distributed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

[memoization]: https://github.com/narumij/Memoization
[collections]: https://github.com/narumij/swift-ac-collections
