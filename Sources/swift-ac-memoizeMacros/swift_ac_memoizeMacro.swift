import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
@_spi(Testing) import SwiftSyntaxMacroExpansion

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
public struct StringifyMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) -> ExprSyntax {
        guard let argument = node.arguments.first?.expression else {
            fatalError("compiler bug: the macro does not have any arguments")
        }

        return "(\(argument), \(literal: argument.description))"
    }
}

public struct MemoizeMacro: BodyMacro {
  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {
    // FIXME: Should be able to support (de-)initializers and accessors as
    // well, but this is a lazy implementation.
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    let funcBaseName = funcDecl.name.text
    let paramNames = funcDecl.signature.parameterClause.parameters.map { param in
      param.parameterName ?? TokenSyntax(.wildcard, presence: .present)
    }

    let passedArgs = DictionaryExprSyntax(
      content: .elements(
        DictionaryElementListSyntax {
          for paramName in paramNames {
            DictionaryElementSyntax(
              key: ExprSyntax("\(literal: paramName.text)"),
              value: DeclReferenceExprSyntax(baseName: paramName)
            )
          }
        }
      )
    )

    return [
      """
      return try await remoteCall(function: \(literal: funcBaseName), arguments: \(passedArgs))
      """
    ]
  }
}

#if true
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
    let paramNames = funcDecl.signature.parameterClause.parameters.map { param in
      param.parameterName ?? TokenSyntax(.wildcard, presence: .present)
    }

    let passedArgs = DictionaryExprSyntax(
      content: .elements(
        DictionaryElementListSyntax {
          for paramName in paramNames {
            DictionaryElementSyntax(
              key: ExprSyntax("\(literal: paramName.text)"),
              value: DeclReferenceExprSyntax(baseName: paramName)
            )
          }
        }
      )
    )
    
    let functionSignature = funcDecl.signature
    
    let codeBlock = funcDecl.body
    
    let arg = funcDecl.signature.parameterClause.parameters.map {
      switch ($0.firstName.tokenKind, $0.firstName, $0.type) {
      case (.wildcard,_,let type):
        return "\(type)"
      case (_,let firstName,let type):
        return "\(firstName):\(type)"
      }
    }.joined(separator: ",")
    
    let cacheKey = funcDecl.signature.parameterClause.parameters.map{
      $0.secondName?.description ?? $0.firstName.description
    }.joined(separator: ",")
    
    let params = funcDecl.signature.parameterClause.parameters.map {
      switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
      case (.wildcard,_,.some(let parameterName)):
        return "\(parameterName)"
      case (_,let firstName,.some(let parameterName)):
        return "\(firstName):\(parameterName)"
      default:
        fatalError()
      }
    }.joined(separator: ",")

    return [
            """
            typealias Arg = (\(raw: arg))
            
            enum Key: CustomKeyProtocol {
              static func value_comp(_ a: Arg, _ b: Arg) -> Bool { a < b }
            }
            
            var cache: ___RedBlackTreeMapBase< Key, \(funcDecl.signature.returnClause?.type ?? "Void")> = .init()

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
            return body(\(raw: params))
            """
    ]
  }
}
#endif

@main
struct swift_ac_memoizePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        StringifyMacro.self,
        MemoizeBodyMacro.self,
    ]
}

