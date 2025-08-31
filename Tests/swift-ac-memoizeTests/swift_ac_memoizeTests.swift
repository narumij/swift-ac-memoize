import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(swift_ac_memoizeMacros)
  import swift_ac_memoizeMacros

  let testMacros: [String: Macro.Type] = [
    "Memoize": InlineMemoizeMacro.self
  ]
#endif

final class swift_ac_memoizeTests: XCTestCase {
  func testMacro() throws {
    #if canImport(swift_ac_memoizeMacros)
      assertMacroExpansion(
        """
        @Memoize(maxCount: 0)
        func test(_ a: Int) -> Int {
          if a == 10 {
            return 10
          }
          return a + test(a - 1)
        }
        """,
        expandedSource: """
          func test(_ a: Int) -> Int {
              let test_cache: MemoizeCache<Int, Int>.LRU = .init(maxCount: 0)
              func test(_ a: Int) -> Int {
                test_cache[.init(a), fallBacking: ___body]
              }
              func ___body(_ a: Int) -> Int {
                if a == 10 {
                  return 10
                }
                return a + test(a - 1)
              }
              return test(a)
          }
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testMacro2() throws {
    #if canImport(swift_ac_memoizeMacros)
      assertMacroExpansion(
        """
        @Memoize(maxCount: Int.max)
        func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
          if x <= yy {
            return yy
          } else {
            return tarai(
              tarai(x - 1, y: yy, z: z),
              y: tarai(yy - 1, y: z, z: x),
              z: tarai(z - 1, y: x, z: yy))
          }
        }
        """,
        expandedSource: """
          func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              let tarai_cache: MemoizeCache<Int, Int, Int, Int>.LRU = .init(maxCount: Int.max)
              func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
                tarai_cache[.init(x, yy, z), fallBacking: ___body]
              }
              func ___body(_ x: Int, y yy: Int, z: Int) -> Int {
                if x <= yy {
                  return yy
                } else {
                  return tarai(
                    tarai(x - 1, y: yy, z: z),
                    y: tarai(yy - 1, y: z, z: x),
                    z: tarai(z - 1, y: x, z: yy))
                }
              }
              return tarai(x, y: yy, z: z)
          }
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }

  func testMacro3() throws {
    #if canImport(swift_ac_memoizeMacros)
      assertMacroExpansion(
        """
        @Memoize
        func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
          if x <= yy {
            return yy
          } else {
            return tarai(
              tarai(x - 1, y: yy, z: z),
              y: tarai(yy - 1, y: z, z: x),
              z: tarai(z - 1, y: x, z: yy))
          }
        }
        """,
        expandedSource: """
          func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              let tarai_cache: MemoizeCache<Int, Int, Int, Int>.Standard = .init()
              func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
                tarai_cache[.init(x, yy, z), fallBacking: ___body]
              }
              func ___body(_ x: Int, y yy: Int, z: Int) -> Int {
                if x <= yy {
                  return yy
                } else {
                  return tarai(
                    tarai(x - 1, y: yy, z: z),
                    y: tarai(yy - 1, y: z, z: x),
                    z: tarai(z - 1, y: x, z: yy))
                }
              }
              return tarai(x, y: yy, z: z)
          }
          """,
        macros: testMacros
      )
    #else
      throw XCTSkip("macros are only supported when running tests for the host platform")
    #endif
  }
  #if false
  #endif
}
