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

```swift
@Memoize
func fib(_ n: Int) -> Int {
  n<2 ? n : fib(n-1) + fib(n-2)
}
print((1..<16).map { fib($0) })
```

マクロの展開は関数内部に対して行われます。

## キャッシュ

### 標準

```swift
@Memoize
```
引数なしの場合、保持するキャッシュサイズは無制限となります。
内部キャッシュにSwift標準のDictionaryを使用します。

### LRU

```swift
@Memoize(maxCount: 20)
```

引数を与えた場合、保持するキャッシュ数を制限します。
内部キャッシュに平衡二分探索木を用いた[LRU (least recently used)](https://en.wikipedia.org/wiki/Cache_replacement_policies#Least_Recently_Used_(LRU))キャッシュを使用します。


```swift
@Memoize(maxCount: Int.max)
```

引数に十分大きな値を与えた場合、実質無制限となりますが、
この場合もLRUキャッシュを使用します。

## 注意事項

- コンパイル環境に載らないと利用できないため、AC実績はまだありません。

- メモ化キャッシュは関数開始時に作成され、関数終了時に開放されます。このため、再帰関数以外でキャッシュ化を利用することはできません。

- 内部にPrivete型を保持しているため、@inlinableにはできません。必要な場合、@usableFromInlineにしてください。

- キャッシュサイズの上限の有無で、関数パラメータの各型が必要とする適合先が変わります。ナシの場合はHashable、アリの場合はComparableとなります。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

[atcoder]: https://atcoder.jp/

