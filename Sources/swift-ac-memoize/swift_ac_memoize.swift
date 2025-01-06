@_exported import AcCollections

@attached(body)
public macro Memoize() = #externalMacro(module: "swift_ac_memoizeMacros", type: "MemoizeBodyMacro")

