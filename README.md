# swift-ac-memoize

`swift-ac-memoize` is an open-source package of memoized recursion macros for competitive programming on [AtCoder][atcoder].

`swift-ac-memoize` は、[AtCoder][atcoder]での利用を想定したメモ化再帰マクロのオープソース・パッケージです。

[![Swift](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml/badge.svg?branch=main)](https://github.com/narumij/swift-ac-memoize/actions/workflows/swift.yml)  
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## 利用の仕方

SwiftPMで swift-ac-libraryを利用する場合は、

以下をPackage.swift に追加してください。
```
dependencies: [
  .package(url: "https://github.com/narumij/swift-ac-memoize.git", from: "0.1.0"),
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

## 使い方

再帰関数の先頭に@Memoizeを付け足すだけです。

キャッシュの上限サイズなしの展開前です。
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

キャッシュの上限サイズなしの展開後は以下のようになります。
標準辞書を用いています。
```swift
func tarai(x: Int, y: Int, z: Int) -> Int {
    enum ___Cache {
      @usableFromInline struct Parameters: Hashable {
        init(x: Int, y: Int, z: Int) {
          self.x = x
          self.y = y
          self.z = z
        }
        @usableFromInline let x: Int
        @usableFromInline let y: Int
        @usableFromInline let z: Int
      }
      @usableFromInline typealias Return = Int
      @usableFromInline typealias Instance = [Parameters: Return]
      @inlinable @inline(__always)
      static func create() -> Instance {
        [:]
      }
    }
    var ___cache = ___Cache.create()
    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = ___Cache.Parameters(x: x, y: y, z: z)
      if let result = ___cache[args] {
        return result
      }
      let r = ___body(x: x, y: y, z: z)
      ___cache[args] = r
      return r
    }
    func ___body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: y, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }
    return tarai(x: x, y: y, z: z)
}

print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))") // 出力: 20
```

キャッシュの上限サイズありの展開前です。
```swift
@Memoize(maxCount: 100)
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

キャッシュの上限サイズありの展開後は以下のようになります。
平衡二分探索木を用いています。
```swift
func tarai(x: Int, y: Int, z: Int) -> Int {
    enum ___Cache: _MemoizationProtocol {
      @usableFromInline typealias Parameters = (x: Int, y: Int, z: Int)
      @usableFromInline typealias Return = Int
      @usableFromInline typealias Instance = Tree
      @inlinable @inline(__always)
      static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
        a < b
      }
      @inlinable @inline(__always)
      static func create() -> Instance {
        .init(maxCount: 100)
      }
    }
    var ___cache = ___Cache.create()
    func tarai(x: Int, y: Int, z: Int) -> Int {
      let args = (x: x, y: y, z: z)
      if let result = ___cache[args] {
        return result
      }
      let r = ___body(x: x, y: y, z: z)
      ___cache[args] = r
      return r
    }
    func ___body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: y, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }
    return tarai(x: x, y: y, z: z)
}
print("Tak 20 10 0 is \(tarai(x: 20, y: 10, z: 0))") // 出力: 20
```

## 注意事項

- コンパイル環境に載らないと利用できないため、AC実績はまだありません。

- メモ化キャッシュは関数開始時に作成され、関数終了時に開放されます。このため、再帰関数以外でキャッシュ化を利用することはできません。

- 内部にPrivete型を保持しているため、@inlinableにはできません。必要な場合、@usableFromInlineにしてください。

- キャッシュサイズの上限の有無で、関数パラメータの各型が必要とする適合先が変わります。ナシの場合はHashable、アリの場合はComparableとなります。

- キャッシュサイズの上限値をInt.maxとすることで、意図的に標準辞書ではなく、平衡二分探索木をキャッシュに利用することが可能です。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

[atcoder]: https://atcoder.jp/

