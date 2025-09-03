import Foundation

public struct MemoizePack<each T> {

  public
    typealias RawValue = (repeat each T)

  public
    var rawValue: RawValue

  @inlinable @inline(__always)
  public init(rawValue: (repeat each T)) {
    self.rawValue = (repeat each rawValue)
  }

  @inlinable @inline(__always)
  public init(_ rawValue: repeat each T) {
    self.rawValue = (repeat each rawValue)
  }
}

extension MemoizePack: Equatable where repeat each T: Equatable {

  @inlinable @inline(__always)
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

  @inlinable @inline(__always)
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

  @inlinable @inline(__always)
  public func hash(into hasher: inout Hasher) {
    for l in repeat (each rawValue) {
      hasher.combine(l)
    }
  }
}

extension MemoizePack: _KeyCustomProtocol where repeat each T: Comparable {

  @inlinable @inline(__always)
  public static func value_comp(
    _ lhs: MemoizePack<repeat each T>, _ rhs: MemoizePack<repeat each T>
  ) -> Bool {
    for (l, r) in repeat (each lhs.rawValue, each rhs.rawValue) {
      if l != r {
        return l < r
      }
    }
    return false
  }
}

extension MemoizePack: Sendable where repeat each T: Sendable { }
