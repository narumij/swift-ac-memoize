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
              enum ___Cache: _ComparableMemoizationCacheProtocol {
                @usableFromInline typealias Parameters = (Int)
                @usableFromInline typealias Return = Int
                @usableFromInline typealias Instance = LRU
                @inlinable @inline(__always)
                static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
                  a < b
                }
                @inlinable @inline(__always)
                static func params(_ a: Int)  -> Parameters {
                  (a)
                }
                @inlinable @inline(__always)
                static func create() -> Instance {
                  .init(maxCount: 0)
                }
              }
              var ___cache = ___Cache.create()
              func test(_ a: Int) -> Int {
                typealias ___C = ___Cache
                let params = ___C.params(a)
                if let result = ___cache[params] {
                  return result
                }
                let r = ___body(a)
                ___cache[params] = r
                return r
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
            enum ___Cache: _ComparableMemoizationCacheProtocol {
              @usableFromInline typealias Parameters = (Int, y: Int, z: Int)
              @usableFromInline typealias Return = Int
              @usableFromInline typealias Instance = LRU
              @inlinable @inline(__always)
              static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
                a < b
              }
              @inlinable @inline(__always)
              static func params(_ x: Int, y yy: Int, z: Int)  -> Parameters {
                (x, y: yy, z: z)
              }
              @inlinable @inline(__always)
              static func create() -> Instance {
                .init(maxCount: Int.max)
              }
            }
            var ___cache = ___Cache.create()
            func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              typealias ___C = ___Cache
              let params = ___C.params(x, y: yy, z: z)
              if let result = ___cache[params] {
                return result
              }
              let r = ___body(x, y: yy, z: z)
              ___cache[params] = r
              return r
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
            enum ___Cache: _HashableMemoizationCacheProtocol {
              @usableFromInline struct Parameters: Hashable {
                @usableFromInline let x: Int
                @usableFromInline let y: Int
                @usableFromInline let z: Int
                init(_ x: Int, y yy: Int, z: Int) {
                    self.x = x
                    self.y = yy
                    self.z = z
                }
              }
              @usableFromInline typealias Return = Int
              @usableFromInline typealias Instance = Standard
              @inlinable @inline(__always)
              static func params(_ x: Int, y yy: Int, z: Int) -> Parameters {
                Parameters(x, y: yy, z: z)
              }
              @inlinable @inline(__always)
              static func create() -> Instance {
                .init()
              }
            }
            var ___cache = ___Cache.create()
            func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
              typealias ___C = ___Cache
              let params = ___C.params(x, y: yy, z: z)
              if let result = ___cache[params] {
                return result
              }
              let r = ___body(x, y: yy, z: z)
              ___cache[params] = r
              return r
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
}
