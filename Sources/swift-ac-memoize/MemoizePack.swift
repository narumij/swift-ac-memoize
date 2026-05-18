import Foundation

public struct MemoizePack<each T> {

  public
    typealias RawValue = (repeat each T)

  public
    var rawValue: RawValue

  @inlinable
  public init(rawValue: (repeat each T)) {
    self.rawValue = (repeat each rawValue)
  }

  @inlinable
  public init(_ rawValue: repeat each T) {
    self.rawValue = (repeat each rawValue)
  }
}

extension MemoizePack: Equatable where repeat each T: Equatable {

  @inlinable
  public static func == (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return false
      }
    }
    return true
  }
}

extension MemoizePack: Comparable where repeat each T: Comparable {

  @inlinable
  public static func < (lhs: MemoizePack<repeat each T>, rhs: MemoizePack<repeat each T>) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension MemoizePack: Hashable where repeat each T: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    for l in repeat (each rawValue) {
      hasher.combine(l)
    }
  }
}

extension MemoizePack: Sendable where repeat each T: Sendable { }
