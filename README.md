# swift-ac-memoize

English | [日本語](README.ja.md)

`swift-ac-memoize` is an open-source package providing memoized recursion macros designed for competitive programming on [AtCoder][atcoder].

[![Swift](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## Usage

To use `swift-ac-memoize` with SwiftPM, add the following to your `Package.swift`.

First, specify the platform:

```swift
platforms: [.macOS(.v14)]
```

Add the dependency:

```swift
dependencies: [
  .package(
    url: "https://github.com/narumij/swift-ac-memoize",
    branch: "release/AtCoder/2025"),
],
```

Add it to your target:

```swift
dependencies: [
  .product(name: "AcMemoize", package: "swift-ac-memoize")
]
```

Import in your source code:

```swift
import AcMemoize
```

## Usage

Simply add `@Memoize` at the beginning of a recursive function.

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

```swift
@Memoize
func fib(_ n: Int) -> Int {
  n < 2 ? n : fib(n - 1) + fib(n - 2)
}
print((1..<16).map { fib($0) })
```

The macro expansion is applied inside the function body.

## Cache

### Default

```swift
@Memoize
```

If no arguments are provided, the cache size is unlimited.  
The internal cache uses Swift’s standard `Dictionary`.

### LRU

```swift
@Memoize(maxCount: 20)
```

If an argument is provided, the cache size is limited.  
An [LRU (least recently used)](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_Recently_Used_(LRU)) cache implemented with a balanced binary search tree is used internally.

```swift
@Memoize(maxCount: Int.max)
```

If a sufficiently large value is given, it effectively behaves as unlimited, but still uses the LRU cache.

- [AC example](https://atcoder.jp/contests/language-test-202505/submissions/69021295)

## Notes

- The memoization cache is created at the beginning of the function and released when the function exits.  
  Therefore, it cannot be used for non-recursive caching.

- Since the implementation uses private types internally, it cannot be marked as `@inlinable`.  
  Use `@usableFromInline` if necessary.

- The required protocol conformance for function parameters depends on whether a cache size limit is specified:
  - No limit → `Hashable`
  - With limit → `Comparable`

## License

This library is distributed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

[atcoder]: https://atcoder.jp/
