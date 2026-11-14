public struct HashLRUCache<Key: Hashable, Value> {

  public let maxCount: Int

  @usableFromInline var slot: [Key: Int] = [:]
  @usableFromInline var keys: [Key] = []
  @usableFromInline var values: [Value] = []
  @usableFromInline var prev: [Int] = []
  @usableFromInline var next: [Int] = []
  @usableFromInline var head = -1
  @usableFromInline var tail = -1

  @inlinable
  public init(maxCount: Int = Int.max) {
    precondition(maxCount > 0, "maxCount must be positive")
    self.maxCount = maxCount
  }

  @inlinable
  public var count: Int { keys.count }

  @inlinable
  mutating func unlink(_ i: Int) {
    if prev[i] >= 0 { next[prev[i]] = next[i] } else { head = next[i] }
    if next[i] >= 0 { prev[next[i]] = prev[i] } else { tail = prev[i] }
  }

  @inlinable
  mutating func pushFront(_ i: Int) {
    prev[i] = -1
    next[i] = head
    if head >= 0 { prev[head] = i } else { tail = i }
    head = i
  }

  @inlinable
  public subscript(key: Key) -> Value? {
    mutating get {
      guard let i = slot[key] else { return nil }
      unlink(i)
      pushFront(i)
      return values[i]
    }
    set {
      guard let newValue else { fatalError("HashLRUCache does not support removal") }
      if let i = slot[key] {
        values[i] = newValue
        unlink(i)
        pushFront(i)
      } else if keys.count < maxCount {
        let i = keys.count
        keys.append(key)
        values.append(newValue)
        prev.append(-1)
        next.append(-1)
        slot[key] = i
        pushFront(i)
      } else {
        let i = tail
        unlink(i)
        slot[keys[i]] = nil
        keys[i] = key
        values[i] = newValue
        slot[key] = i
        pushFront(i)
      }
    }
  }
}

extension HashLRUCache: MemoCache {}
