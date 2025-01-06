# swift-ac-memoize

`swift-ac-collections` は、[AtCoder][atcoder]での利用を想定したメモ化マクロのオープソース・パッケージです。

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

## 注意事項

- コンパイル環境に載らないと利用できないため、AC実績はまだありません。

- 内部にPrivete型を保持しているため、@inlinableにはできません。必要な場合、@usableFromInlineにしてください。

- メモ化キャッシュは関数開始時に作成され、関数終了時に開放されます。

- タプルに混ぜた際に、タプル同士の比較が利用できなくなるような型は再帰関数の引数に利用できません。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

[atcoder]: https://atcoder.jp/

