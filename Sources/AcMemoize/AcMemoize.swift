@_exported import Memoization
import AcCollections

extension RedBlackTreeDictionary: @retroactive MemoCache {}

#if ENABLE_EXPERIMENTAL_LRU
  extension LRUCache: @retroactive MemoCache {}
#endif

#if ENABLE_OPTIONAL_ELEMENT_BUFFER
  extension OptionalElementBuffer: @retroactive MemoCache {
    public typealias Key = Int
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get { element(at: key) }
      nonmutating set { setElement(newValue, at: key) }
    }
  }

  extension OptionalElementBuffer2D: @retroactive MemoCache {
    public typealias Key = MemoizePack2<Int, Int>
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get { element(at: key.a, key.b) }
      nonmutating set { setElement(newValue, at: key.a, key.b) }
    }
  }

  extension OptionalElementBuffer3D: @retroactive MemoCache {
    public typealias Key = MemoizePack3<Int, Int, Int>
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get { element(at: key.a, key.b, key.c) }
      nonmutating set { setElement(newValue, at: key.a, key.b, key.c) }
    }
  }

  extension OptionalElementBuffer4D: @retroactive MemoCache {
    public typealias Key = MemoizePack4<Int, Int, Int, Int>
    public typealias Value = Element
    public subscript(key: Key) -> Element? {
      get { element(at: key.a, key.b, key.c, key.d) }
      nonmutating set { setElement(newValue, at: key.a, key.b, key.c, key.d) }
    }
  }
#endif
