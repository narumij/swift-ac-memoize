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
  .package(url: "https://github.com/narumij/swift-ac-library.git", from: "0.1.0"),
],
```

ビルドターゲットに以下を追加します。

```
  dependencies: [
    .product(name: "AtCoder", package: "swift-ac-library")
  ]
```

ソースコードに以下を追加します。
```
import AcMemoize
```

## 使い方

再帰関数の先頭に@Memoizeを付け足すだけです。

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

上のソースコードは、おおよそ以下のように展開されます。
```swift
static func tarai(x: Int, y: Int, z: Int) -> Int {
  
  typealias Args = (x: Int, y: Int, z: Int)
  
  enum Key: CustomKeyProtocol {
    @inlinable @inline(__always)
    static func value_comp(_ a: Args, _ b: Args) -> Bool { a < b }
  }
  
  var storage: MemoizeCacheBase<Key, Int> = .init()
  
  func tarai(x: Int, y: Int, z: Int) -> Int {
    let args = (x,y,z)
    if let result = storage[args] {
      return result
    }
    let r = body(x: x, y: y, z: z)
    storage[args] = r
    return r
  }
  
  func body(x: Int, y: Int, z: Int) -> Int {
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

フィボナッチ数は以下のように書けます。
```swift
@Memoize
func fibonacci(_ n: Int) -> Int {
    if n <= 1 { return n }
    return fibonacci(n - 1) + fibonacci(n - 2)
}
print(fibonacci(40)) // Output: 102_334_155
```

## 注意事項

- コンパイル環境に載らないと利用できないため、AC実績はまだありません。

- メモ化キャッシュは関数開始時に作成され、関数終了時に開放されます。このため、再帰関数以外でメモ化を利用することができません。

- 内部にPrivete型を保持しているため、@inlinableにはできません。必要な場合、@usableFromInlineにしてください。

- タプルに混ぜた際に、タプル同士の比較が利用できなくなるような型は再帰関数の引数に利用できません。任意型を利用する際は、Comparableに適合してみてください。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

[atcoder]: https://atcoder.jp/

