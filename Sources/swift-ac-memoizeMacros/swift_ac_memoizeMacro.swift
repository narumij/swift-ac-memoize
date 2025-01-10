import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct MemoizeBodyMacro: BodyMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    var maxCount: String?

    let arguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []

    for argument in arguments {
      if let label = argument.label?.text, label == "maxCount" {
        if let valueExpr = argument.expression.as(IntegerLiteralExprSyntax.self) {
          maxCount = valueExpr.literal.text
          break
        }
      }
    }

    if let maxCount {
      return [
        """
        \(treeCache(funcDecl, maxCount: maxCount))
        var \(cacheName(funcDecl)) = ___Cache.create()
        \(functionBody(funcDecl, initialize: ""))
        """
      ]
    } else {
      return [
        """
        \(hashCache(funcDecl))
        var \(cacheName(funcDecl)) = ___Cache.create()
        \(functionBody(funcDecl, initialize: "___Cache.Parameters"))
        """
      ]
    }
  }
}

func structParameters(_ name: TypeSyntax, _ parameterClause: FunctionParameterClauseSyntax)
  -> CodeBlockItemSyntax
{

  let inits = parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return "self.\(parameterName) = \(parameterName)"
    case (_, let firstName, .some(let parameterName)):
      return "self.\(firstName.trimmed) = \(parameterName)"
    case (_, _, .none):
      fatalError()
    }
  }.joined(separator: "\n")

  let members = parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName, $0.type) {
    case (.wildcard, _, .some(let parameterName), let type):
      return "@usableFromInline let \(parameterName): \(type)"
    case (_, let firstName, _, let type):
      return "@usableFromInline let \(firstName.trimmed): \(type)"
    }
  }.joined(separator: "\n")

  return """
    @usableFromInline struct \(name): Hashable {
      init\(parameterClause){
        \(raw: inits)
      }
      \(raw: members)
    }
    """
}

func hashCache(_ funcDecl: FunctionDeclSyntax) -> CodeBlockItemSyntax {
  return """
    enum ___Cache {
      \(structParameters("Parameters", funcDecl.signature.parameterClause))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = [Parameters:Return]
      @inlinable @inline(__always)
      static func create() -> Instance {
        [:]
      }
    }
    """
}

func treeCache(_ funcDecl: FunctionDeclSyntax, maxCount limit: String?) -> CodeBlockItemSyntax {
  let params = typeParameter(funcDecl)
  return """
    enum ___Cache: _MemoizationProtocol {
      @usableFromInline typealias Parameters = (\(raw: params))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = Tree
      @inlinable @inline(__always)
      static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
        a < b
      }
      @inlinable @inline(__always)
      static func create() -> Instance {
        .init(maximumCapacity: \(raw: limit ?? "Int.max"))
      }
    }
    """
}

func functionBody(_ funcDecl: FunctionDeclSyntax, initialize: String) -> CodeBlockItemSyntax {

  let cache: TokenSyntax = cacheName(funcDecl)
  let params = callParameters(funcDecl)

  return """
    func \(funcDecl.name)\(funcDecl.signature){
      let args = \(raw: initialize)(\(raw: params))
      if let result = \(cache)[args] {
        return result
      }
      let r = ___body(\(raw: params))
      \(cache)[args] = r
      return r
    }
    func ___body\(funcDecl.signature)\(funcDecl.body)
    return \(raw: funcDecl.name)(\(raw: params))
    """
}

func callParameters(_ funcDecl: FunctionDeclSyntax) -> String {
  funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return "\(parameterName)"
    case (_, let firstName, .some(let parameterName)):
      return "\(firstName.trimmed): \(parameterName)"
    case (_, _, .none):
      fatalError()
    }
  }.joined(separator: ", ")
}

func typeParameter(_ funcDecl: FunctionDeclSyntax) -> String {
  funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.type) {
    case (.wildcard,_,let type):
      return "\(type)"
    case (_,let firstName,let type):
      return "\(firstName.trimmed): \(type)"
    }
  }.joined(separator: ", ")
}

func cacheName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
//  "\(raw: funcDecl.name.text)_cache"
  "___cache"
}

func returnType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {
  funcDecl.signature.returnClause?.type.trimmed ?? "Void"
}

@main
struct swift_ac_memoizePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    MemoizeBodyMacro.self
  ]
}
