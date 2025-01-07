import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
@_spi(Testing) import SwiftSyntaxMacroExpansion

public struct MemoizeBodyMacro: BodyMacro {
  
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }
    
    let funcBaseName = funcDecl.name.text
    let functionSignature = funcDecl.signature
    let codeBlock = funcDecl.body
    let args = funcDecl.signature.parameterClause.parameters.map {
      switch ($0.firstName.tokenKind, $0.firstName, $0.type) {
      case (.wildcard,_,let type):
        return "\(type)"
      case (_,let firstName,let type):
        return "\(firstName.trimmed): \(type)"
      }
    }.joined(separator: ", ")
    let cacheKey = funcDecl.signature.parameterClause.parameters.map{
      $0.parameterName?.description ?? $0.firstName.description
    }.joined(separator: ",")
    let params = funcDecl.signature.parameterClause.parameters.map {
      switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
      case (.wildcard,_,.some(let parameterName)):
        return "\(parameterName)"
      case (_,let firstName,.some(let parameterName)):
        return "\(firstName.trimmed): \(parameterName)"
      case (_,_,.none):
        fatalError()
      }
    }.joined(separator: ", ")

    return [
            """
            typealias Args = (\(raw: args))
            
            enum Key: CustomKeyProtocol {
              @inlinable @inline(__always)
              static func value_comp(_ a: Args, _ b: Args) -> Bool { a < b }
            }
            
            var cache: MemoizeCacheBase<Key,\(raw: funcDecl.signature.returnClause?.type.trimmedDescription ?? "Void")> = .init()

            func \(raw: funcBaseName)\(functionSignature){
              let args = (\(raw: cacheKey))
              if let result = cache[args] {
                return result
              }
              let r = body(\(raw: params))
              cache[args] = r
              return r
            }
            
            func body\(functionSignature)\(codeBlock)
            
            return \(raw: funcBaseName)(\(raw: params))
            """
    ]
  }
}

@main
struct swift_ac_memoizePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MemoizeBodyMacro.self,
    ]
}

