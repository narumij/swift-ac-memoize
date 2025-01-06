//
//  memoizeDPTests.swift
//  swift-ac-memoize
//
//  Created by narumij on 2025/01/07.
//

import XCTest
import AcMemoize

final class memoizeDPTests: XCTestCase {

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
}
