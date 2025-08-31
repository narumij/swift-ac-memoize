import XCTest
import AcMemoize

final class memoizeTests: XCTestCase {

  struct DP_G {
    let N = 4
    let M = 5
    let xy: [(x: Int, y: Int)] = [
      (1,2),
      (1,3),
      (3,2),
      (2,4),
      (3,4),
    ]
    
    func solve() -> Int {
      var G: [[Int]] = repeatElement([], count: M) + []
      
      for i in 0 ..< M {
        let (x,y) = xy[i]
        G[x - 1].append(y - 1)
      }
      
      @Memoize
      func rec(_ v: Int) -> Int {
        G[v].map { rec($0) + 1 }.max() ?? 0
      }
      
      var res = 0
      for v in 0 ..< N {
          res = max(res, rec(v))
      }
      return res
    }
  }

  func testDP_G() throws {
    XCTAssertEqual(DP_G().solve(), 3)
  }
  
  func testTraiStandard() throws {
    @Memoize
    func tarai(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: y, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }
    XCTAssertEqual(tarai(x: 40, y: 20, z: 0), 40)
  }
  
  func testTraiLRU() throws {
    @Memoize(maxCount: Int.max)
    func tarai(x: Int, y: Int, z: Int) -> Int {
      if x <= y {
        return y
      } else {
        return tarai(
          x: tarai(x: x - 1, y: y, z: z),
          y: tarai(x: y - 1, y: z, z: x),
          z: tarai(x: z - 1, y: x, z: y))
      }
    }
    XCTAssertEqual(tarai(x: 40, y: 20, z: 0), 40)
  }
  
  func testFibStandard() throws {
    @Memoize()
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
    XCTAssertEqual((1..<16).map { fibonacci($0) }, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610])
    XCTAssertEqual(fibonacci(40),102_334_155)
  }
  
  func testFibLRU() throws {
    @Memoize(maxCount: 100)
    func fibonacci(_ n: Int) -> Int {
        if n <= 1 { return n }
        return fibonacci(n - 1) + fibonacci(n - 2)
    }
    XCTAssertEqual((1..<16).map { fibonacci($0) }, [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 377, 610])
    XCTAssertEqual(fibonacci(40),102_334_155)
  }
}
