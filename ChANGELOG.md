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

## [0.2.3] - 2026-5-5
### Changed
- READMEを更新し、日本語版を追加

## [0.2.2] - 2026-1-26
### Changed
- swift-ac-collectionsの依存を`compatible/AtCoder/2025`ブランチに変更

## [0.2.1] - 2025-10-20
### Fixed
- 対象をmacOS 15に戻し、コンパイルエラーを修正

## [0.2.0] - 2025-10-12
### Changed
- swift-ac-collectionsの依存を0.2.0以降に変更
- `MemoizePack`の`_KeyCustomProtocol`への適合を削除

## [0.1.12] - 2025-9-16
### Changed
- swift-tools-versionを6.2に変更
- swift-syntaxを602.0.0に固定

## [0.1.11] - 2025-9-3
### Changed
- READMEを更新

## [0.1.10] - 2025-9-3
### Added
- `MemoizeCache`と`MemoizePack`を追加
### Changed
- swift-ac-collectionsの依存を0.1.43以降に変更

## [0.1.9] - 2025-8-31
### Removed
- サンプルのクライアントを削除
### Changed
- テストを整理

## [0.1.8] - 2025-8-31
### Changed
- swift-ac-collectionsの依存を0.1.42以降に変更

## [0.1.7] - 2025-8-31
### Changed
- swift-ac-collectionsの依存を0.1.42に固定
- 対象をmacOS 14に変更

## [0.1.6] - 2025-8-31
### Changed
- マクロを`InlineMemoizeMacro`に作り直し、`@Memoize()`と`@Memoize(maxCount:)`に分割
- swift-tools-versionを6.1、対象をmacOS 15に変更
- swift-syntaxを601.0.1に固定
- swift-ac-collectionsの依存を`release/AtCoder/2025`ブランチに変更

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
