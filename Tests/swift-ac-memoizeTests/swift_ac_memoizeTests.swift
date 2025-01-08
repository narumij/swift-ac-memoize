import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(swift_ac_memoizeMacros)
  import swift_ac_memoizeMacros

  let testMacros: [String: Macro.Type] = [
    "Memoize": MemoizeBodyMacro.self
  ]
#endif

final class swift_ac_memoizeTests: XCTestCase {
  func testMacro() throws {
    #if canImport(swift_ac_memoizeMacros)
      assertMacroExpansion(
        """
        @Memoize
        func test(_ a: Int) -> Int {
          if a == 10 {
            return 10
          }
          return a + test(a - 1)
        }
        """,
        expandedSource: """
          func test(_ a: Int) -> Int {
              struct Cache {
                enum Memoize: _MemoizationProtocol {
                  typealias Parameter = (Int)
                  typealias Return = Int
                  @inlinable @inline(__always)
                  static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool {
                      a < b
                  }
                }
                var memo: Memoize.Tree = .init(maximumCapacity: Int.max)
              }

              var cache = Cache()

              func test(_ a: Int) -> Int {
                let args = (a)
                if let result = cache.memo[args] {
                  return result
                }
                let r = body(a)
                cache.memo[args] = r
                return r
              }

              func body(_ a: Int) -> Int {
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
              struct Cache {
                enum Memoize: _MemoizationProtocol {
                  typealias Parameter = (Int, y: Int, z: Int)
                  typealias Return = Int
                  @inlinable @inline(__always)
                  static func value_comp(_ a: Parameter, _ b: Parameter) -> Bool {
                      a < b
                  }
                }
                var memo: Memoize.Tree = .init(maximumCapacity: Int.max)
              }

              var cache = Cache()

              func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
                let args = (x,yy,z)
                if let result = cache.memo[args] {
                  return result
                }
                let r = body(x, y: yy, z: z)
                cache.memo[args] = r
                return r
              }

              func body(_ x: Int, y yy: Int, z: Int) -> Int {
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
}
