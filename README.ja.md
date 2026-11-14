# swift-ac-memoize

[English](README.md) | 日本語

`swift-ac-memoize` は、[Memoization][memoization]のメモ化マクロと、[swift-ac-collections][collections]のコンテナをつなぐパッケージです。

[![Swift](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 利用の仕方

以下をPackage.swift に追加してください。
```
platforms: [.macOS(.v15)]
```

```
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-memoize", branch: "main"),
],
```

ビルドターゲットに以下を追加します。

```
  dependencies: [
    .product(name: "AcMemoize", package: "swift-ac-memoize")
  ]
```

ソースコードに以下を追加します。
```
import AcMemoize
```

`AcMemoize`は`Memoization`を再エクスポートします。

### AtCoder 2025 のジャッジ

AtCoder 2025 のジャッジ環境向けの旧版は、`compatible/AtCoder/2025`ブランチにあります。

```
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-memoize", branch: "compatible/AtCoder/2025"),
],
```

## 使い方

`@Memoize`、`@Memoizable`、生成される別名`fooCache<...>`の使い方は[Memoization][memoization]と同じです。

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
print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))") // 出力: 20
```

このパッケージは、swift-ac-collectionsのコンテナを`MemoCache`に適合させます。
`cache:`付きの関数に渡すと、キャッシュに使えます。

## 使えるキャッシュ

### RedBlackTreeDictionary

赤黒木の辞書です。引数の型は`Comparable`であれば使えます。

```swift
@Memoizable
func paths(_ p: Point) -> Int {
  p.x == 0 || p.y == 0 ? 1 : paths(Point(x: p.x - 1, y: p.y)) + paths(Point(x: p.x, y: p.y - 1))
}

var cache = pathsCache<RedBlackTreeDictionary>()
paths(Point(x: 16, y: 16), cache: &cache)
```

### LRUCache

保持する数を制限する[LRU (least recently used)](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_Recently_Used_(LRU))キャッシュです。
引数の型は`Comparable`であれば使えます。コピーできない型です。

```swift
var cache = pathsCache<LRUCache>(maxCount: 64)
paths(Point(x: 16, y: 16), cache: &cache)
```

swift-ac-collectionsでは実験的な型のため、APIが変わることがあります。

### OptionalElementBuffer

`Int`の引数を添字にする配列です。1次元から4次元まであります。
引数の範囲に合わせて大きさを決めます。

```swift
@Memoizable
func fib(_ n: Int) -> Int {
  n < 2 ? n : fib(n - 1) + fib(n - 2)
}

var cache = fibCache<OptionalElementBuffer>(capacity: 91)
fib(90, cache: &cache)
```

```swift
// @Memoizable func rec(_ i: Int, _ j: Int, _ k: Int) -> Double の場合
var cache = recCache<OptionalElementBuffer3D>(width: 11, height: 11, depth: 11)
```

## トレイト

`LRUCache`と`OptionalElementBuffer`の接続は、トレイトで切り替えます。どちらも既定で有効です。

| トレイト | 内容 |
| --- | --- |
| `ENABLE_EXPERIMENTAL_LRU` | `LRUCache`を接続します |
| `ENABLE_OPTIONAL_ELEMENT_BUFFER` | `OptionalElementBuffer`を接続します |

無効にする場合は、依存の指定でトレイトを選びます。

```
.package(url: "https://github.com/narumij/swift-ac-memoize", branch: "main", traits: []),
```

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

[memoization]: https://github.com/narumij/Memoization
[collections]: https://github.com/narumij/swift-ac-collections
