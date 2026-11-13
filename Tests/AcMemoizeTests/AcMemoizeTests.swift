import AcCollections
import AcMemoize
import Testing

/// 比較はできるがハッシュはできない引数
struct Point: Comparable {
  var x: Int
  var y: Int
  static func < (a: Point, b: Point) -> Bool { (a.x, a.y) < (b.x, b.y) }
}

@Memoizable
func paths(_ p: Point) -> Int {
  p.x == 0 || p.y == 0 ? 1 : paths(Point(x: p.x - 1, y: p.y)) + paths(Point(x: p.x, y: p.y - 1))
}

@Memoize
func tarai(x: Int, y: Int, z: Int) -> Int {
  x <= y ? y : tarai(x: tarai(x: x - 1, y: y, z: z), y: tarai(x: y - 1, y: z, z: x), z: tarai(x: z - 1, y: x, z: y))
}

@Memoizable
func fib(_ n: Int) -> Int {
  n < 2 ? n : fib(n - 1) + fib(n - 2)
}

// EDPC J - Sushi
struct Sushi {
  let n: Int

  @Memoizable
  func rec(_ i: Int, _ j: Int, _ k: Int) -> Double {
    if i == 0, j == 0, k == 0 { return 0.0 }
    var res = 0.0
    if i > 0 { res += rec(i - 1, j, k) * Double(i) }
    if j > 0 { res += rec(i + 1, j - 1, k) * Double(j) }
    if k > 0 { res += rec(i, j + 1, k - 1) * Double(k) }
    res += Double(n)
    res *= 1.0 / Double(i + j + k)
    return res
  }
}

struct RedBlackTreeDictionaryTests {

  @Test func cacheType() {
    let cache = Memo<Point, Int>.Cache<RedBlackTreeDictionary>()
    #expect(type(of: cache) == RedBlackTreeDictionary<MemoizePack<Point>, Int>.self)
  }

  @Test func comparableOnlyArgument() {
    var cache = Memo<Point, Int>.Cache<RedBlackTreeDictionary>()
    #expect(paths(Point(x: 16, y: 16), cache: &cache) == 601_080_390)
    #expect(cache.count == 17 * 17 - 1)
  }

  @Test func multipleArguments() {
    var cache = CountingCache(Memo<Int, Int, Int, Int>.Cache<RedBlackTreeDictionary>())
    #expect(tarai(x: 24, y: 12, z: 0, cache: &cache) == 24)
    #expect(cache.hits > 0)
  }
}

#if ENABLE_EXPERIMENTAL_LRU
  struct LRUCacheTests {

    @Test func boundedCache() {
      var cache = Memo<Point, Int>.Cache<LRUCache>(maxCount: 64)
      #expect(paths(Point(x: 16, y: 16), cache: &cache) == 601_080_390)
      #expect(cache.count == 64)
    }

    @Test func counting() {
      var cache = NoncopyableCountingCache(Memo<Point, Int>.Cache<LRUCache>(maxCount: 64))
      _ = paths(Point(x: 16, y: 16), cache: &cache)
      #expect(cache.hits > 0)
      #expect(cache.misses > 0)
    }
  }
#endif

#if ENABLE_OPTIONAL_ELEMENT_BUFFER
  struct OptionalElementBufferTests {

    @Test func oneDimension() {
      var cache = Memo<Int, Int>.Cache<OptionalElementBuffer>(capacity: 91)
      #expect(fib(90, cache: &cache) == 2_880_067_194_370_816_120)
    }

    @Test func threeDimensions() {
      let s = Sushi(n: 10)
      var cache = Memo<Int, Int, Int, Double>.Cache<OptionalElementBuffer3D>(width: 11, height: 11, depth: 11)
      #expect(abs(s.rec(2, 3, 5, cache: &cache) - 54.48064457488221) < 1e-9)
    }
  }
#endif
