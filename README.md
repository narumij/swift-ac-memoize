# swift-ac-memoize

`swift-ac-collections` は、[AtCoder][atcoder]での利用を想定したメモ化マクロのオープソース・パッケージです。

## 使い方

インポートして、再帰関数の先頭に@Memoizeを付け足すだけです。


```swift
import AcMemoize
```

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

コンパイル環境に載らないと利用できないため、AC実績はまだありません。

## ライセンス

このライブラリは [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0) に基づいて配布しています。  

[atcoder]: https://atcoder.jp/

