@_exported import Memoization
import AcCollections

extension RedBlackTreeDictionary: @retroactive MemoCache {}

#if ENABLE_EXPERIMENTAL_LRU
  extension LRUCache: @retroactive MemoCache {}
#endif

#if ENABLE_OPTIONAL_ELEMENT_BUFFER
  extension OptionalElementBuffer: @retroactive MemoCache {
    public typealias Key = MemoizePack<Int>
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get { element(at: key.rawValue) }
      nonmutating set { setElement(newValue, at: key.rawValue) }
    }
  }

  extension OptionalElementBuffer2D: @retroactive MemoCache {
    public typealias Key = MemoizePack<Int, Int>
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get {
        let (x, y) = key.rawValue
        return element(at: x, y)
      }
      nonmutating set {
        let (x, y) = key.rawValue
        setElement(newValue, at: x, y)
      }
    }
  }

  extension OptionalElementBuffer3D: @retroactive MemoCache {
    public typealias Key = MemoizePack<Int, Int, Int>
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get {
        let (x, y, z) = key.rawValue
        return element(at: x, y, z)
      }
      nonmutating set {
        let (x, y, z) = key.rawValue
        setElement(newValue, at: x, y, z)
      }
    }
  }

  extension OptionalElementBuffer4D: @retroactive MemoCache {
    public typealias Key = MemoizePack<Int, Int, Int, Int>
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get {
        let (x, y, z, w) = key.rawValue
        return element(at: x, y, z, w)
      }
      nonmutating set {
        let (x, y, z, w) = key.rawValue
        setElement(newValue, at: x, y, z, w)
      }
    }
  }
#endif
