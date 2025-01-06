@_exported import AcCollections

public typealias MemoizeCacheBase = ___RedBlackTreeMapBase

@attached(body)
public macro Memoize() = #externalMacro(module: "swift_ac_memoizeMacros", type: "MemoizeBodyMacro")

