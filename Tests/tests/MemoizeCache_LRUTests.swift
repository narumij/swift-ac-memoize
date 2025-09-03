import AcMemoize
import XCTest

final class MemoizeCache_LRUTests: XCTestCase {

  func tarai(x: Int, y: Int, z: Int) -> Int {
    let ___tarai_cache: MemoizeCache<Int, Int, Int, Int>.LRU = .init(maxCount: Int.max)
    func tarai(x: Int, y: Int, z: Int) -> Int {
      ___tarai_cache[.init(x, y, z), fallBacking: ___body]
    }
    func ___body(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: y, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }
    return tarai(x: x, y: y, z: z)
  }
  
  func testTarai() throws {
    XCTAssertEqual(tarai(x: 20, y: 10, z: 0), 20)
  }
}
