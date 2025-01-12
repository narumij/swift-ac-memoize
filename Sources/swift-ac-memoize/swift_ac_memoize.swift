@_exported import RedBlackTreeModule

@attached(body)
public macro Memoize(maxCount: Int? = nil) = #externalMacro(module: "swift_ac_memoizeMacros", type: "MemoizeBodyMacro")

