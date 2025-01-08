@_exported import RedBlackTreeModule

//public typealias MemoizeCacheBase = ___RedBlackTreeMapBase
public typealias CustomKeyProtocol = KeyCustomProtocol

@attached(body)
public macro Memoize(limit maximumCapacity: Int = Int.max) = #externalMacro(module: "swift_ac_memoizeMacros", type: "MemoizeBodyMacro")

