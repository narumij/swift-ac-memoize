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
              enum ___Cache: _MemoizationProtocol {
                @usableFromInline typealias Parameters = (Int)
                @usableFromInline typealias Return = Int
                @usableFromInline typealias Instance = LRU
                @inlinable @inline(__always)
                static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
                  a < b
                }
                @inlinable @inline(__always)
                static func create() -> Instance {
                  Instance(maxCount: 0)
                }
              }
              var ___cache = ___Cache.create()
              func test(_ a: Int) -> Int {
                let args = (a)
                if let result = ___cache[args] {
                  return result
                }
                let r = ___body(a)
                ___cache[args] = r
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
        @Memoize(maxCount: 0)
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
              enum ___Cache: _MemoizationProtocol {
                @usableFromInline typealias Parameters = (Int, y: Int, z: Int)
                @usableFromInline typealias Return = Int
                @usableFromInline typealias Instance = LRU
                @inlinable @inline(__always)
                static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
                  a < b
                }
                @inlinable @inline(__always)
                static func create() -> Instance {
                  Instance(maxCount: 0)
                }
              }
              var ___cache = ___Cache.create()
              func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
                let args = (x, y: yy, z: z)
                if let result = ___cache[args] {
                  return result
                }
                let r = ___body(x, y: yy, z: z)
                ___cache[args] = r
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
              enum ___Cache {
                @usableFromInline struct Parameters: Hashable {
                  init(_ x: Int, y yy: Int, z: Int) {
                    self.x = x
                self.y = yy
                self.z = z
                  }
                  @usableFromInline let x: Int
                @usableFromInline let y: Int
                @usableFromInline let z: Int
                }
                @usableFromInline typealias Return = Int
                @usableFromInline typealias Instance = [Parameters: Return]
                @inlinable @inline(__always)
                static func create() -> Instance {
                  [:]
                }
              }
              var ___cache = ___Cache.create()
              func tarai(_ x: Int, y yy: Int, z: Int) -> Int {
                let args = ___Cache.Parameters(x, y: yy, z: z)
                if let result = ___cache[args] {
                  return result
                }
                let r = ___body(x, y: yy, z: z)
                ___cache[args] = r
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
