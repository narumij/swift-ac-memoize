//
//  memoizeDPTests.swift
//  swift-ac-memoize
//
//  Created by narumij on 2025/01/07.
//

import XCTest
import AcMemoize

final class memoizeDPTests: XCTestCase {

  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
  }

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

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
