# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Changed
- MemoizationとAcCollectionsをつなぐ構成に刷新
- マクロ本体と`MemoCache`をMemoizationへ移し、`AcMemoize`から再エクスポート
- `RedBlackTreeDictionary`を`MemoCache`に適合
- AtCoder 2025のジャッジ向けの旧版を`compatible/AtCoder/2025`ブランチに移動

### Added
- トレイト`ENABLE_EXPERIMENTAL_LRU`で、`LRUCache`を`MemoCache`に適合
- トレイト`ENABLE_OPTIONAL_ELEMENT_BUFFER`で、`OptionalElementBuffer`の1次元から4次元までを`MemoCache`に適合
- 両トレイトを既定で有効化

### Removed
- `@Memoize(maxCount:)`。上限付きのキャッシュは`Memo<...>.Cache<LRUCache>(maxCount:)`を渡す

## [0.1.5] - 2025-2-1
### Changed
- swift-ac-collectionsのバージョンを更新

## [0.1.4] - 2025-1-27
### Changed
- swift-ac-collectionsのバージョンを更新

## [0.1.3] - 2025-1-26
### Changed
- swift-ac-collectionsのバージョンを更新

## [0.1.2] - 2025-1-26
### Changed
- swift-ac-collectionsのバージョンを更新

## [0.1.1] - 2025-1-19
### Changed
- swift-ac-collectionsのバージョンを更新

## [0.1.0] - 2025-1-18
### Changed
- バージョン番号の変更
- 依存パッケージバージョンの固定

## [0.0.8] - 2025-1-13
### Fixed
- maxCount:にInt.maxを指定した際にLRUキャッシュとなるよう修正

## [0.0.7] - 2025-1-13
### Changed
- キャッシュを標準辞書とLRU専用コンテナの併用に変更

## [0.0.6] - 2025-1-8
### Changed
- swift-ac-collectionの依存バージョンを0.1.4に変更
- @MemoizeのmaximumCapacityパラメータを、maxCountに変更

## [0.0.5] - 2025-1-7
### Added
- @MemoizeにmaximumCapacityパラメータを追加

## [0.0.4] - 2025-1-7
### Changed
- 再帰開始内部関数の修正

## [0.0.3] - 2025-1-7
### Changed
- リリースミスの解消

## [0.0.2] - 2025-1-6
### Changed
- 型名、MemoizeCacheBaseを追加

## [0.0.1] - 2025-1-6
### Changed
- Memoizeマクロの追加

## [0.0.0] - 2025-1-6
### Changed
- テンプレートからの初期化
