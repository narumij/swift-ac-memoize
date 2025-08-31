@_exported import RedBlackTreeModule

@attached(body)
public macro Memoize() = #externalMacro(module: "swift_ac_memoizeMacros", type: "InlineMemoizeMacro")

@attached(body)
public macro Memoize(maxCount: Int) = #externalMacro(module: "swift_ac_memoizeMacros", type: "InlineMemoizeMacro")
