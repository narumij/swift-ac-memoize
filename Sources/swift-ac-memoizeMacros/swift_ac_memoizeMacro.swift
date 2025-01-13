import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

@main
struct swift_ac_memoizePlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    MemoizeBodyMacro.self
  ]
}

public struct MemoizeBodyMacro: BodyMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    let maxCount: String? = maxCount(node)

    if let maxCount {
      return [
        """
        \(lruCache(funcDecl, maxCount: maxCount))
        """,
        """
        var \(cacheName(funcDecl)) = \(cacheTypeName(funcDecl)).create()
        """
      ] +
      functionBody(funcDecl, initialize: "")
    } else {
      return [
        """
        \(hashCache(funcDecl))
        """,
        """
        var \(cacheName(funcDecl)) = \(cacheTypeName(funcDecl)).create()
        """
      ] +
      functionBody(funcDecl, initialize: "\(cacheTypeName(funcDecl)).Parameters")
    }
  }
}

func structParameters(_ name: TypeSyntax, _ parameterClause: FunctionParameterClauseSyntax)
-> Syntax
{

  let ii: (FunctionParameterSyntax) -> (TokenSyntax, TokenSyntax) = {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return (parameterName, parameterName)
    case (_, let firstName, .some(let parameterName)):
      return (firstName.trimmed, parameterName)
    case (_, _, .none):
      fatalError()
    }
  }

  let mm: (FunctionParameterSyntax) -> (TokenSyntax, TypeSyntax) = {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName, $0.type) {
    case (.wildcard, _, .some(let parameterName), let type):
      return (parameterName, type)
    case (_, let firstName, _, let type):
      return (firstName.trimmed, type)
    }
  }
  
  let inheritedClause = InheritanceClauseSyntax {
    InheritedTypeSyntax(type: IdentifierTypeSyntax(name: .identifier("Hashable")))
  }
  
  return StructDeclSyntax(name: "\(name)", inheritanceClause: inheritedClause) {
    for (propertyName, propertyType) in parameterClause.parameters.map(mm) {
      DeclSyntax("@usableFromInline let \(propertyName): \(propertyType)")
    }
    InitializerDeclSyntax(signature: .init(parameterClause: parameterClause)) {
      for (propertyName, parameterName) in parameterClause.parameters.map(ii) {
        ExprSyntax("self.\(propertyName) = \(parameterName)\n")
      }
    }
  }
  .formatted()
}

func hashCache(_ funcDecl: FunctionDeclSyntax) -> DeclSyntax {
  return """
    enum \(cacheTypeName(funcDecl)): _HashableMemoizationCacheProtocol {
      @usableFromInline \(structParameters("Parameters", funcDecl.signature.parameterClause))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = Standard
      @inlinable @inline(__always)
      static func params\(funcDecl.signature.parameterClause)-> Parameters {
        Parameters(\(paramsExpr(funcDecl)))
      }
      @inlinable @inline(__always)
      static func create() -> Instance {
        .init()
      }
    }
    """
}

func lruCache(_ funcDecl: FunctionDeclSyntax, maxCount limit: String?) -> DeclSyntax {
  return """
    enum \(cacheTypeName(funcDecl)): _ComparableMemoizationCacheProtocol {
      @usableFromInline typealias Parameters = (\(raw: tupleTypeElement(funcDecl)))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = LRU
      @inlinable @inline(__always)
      static func value_comp(_ a: Parameters, _ b: Parameters) -> Bool {
        a < b
      }
      @inlinable @inline(__always)
      static func params\(funcDecl.signature.parameterClause) -> Parameters {
        (\(paramsExpr(funcDecl)))
      }
      @inlinable @inline(__always)
      static func create() -> Instance {
        .init(maxCount: \(raw: limit ?? "Int.max"))
      }
    }
    """
}

func functionBody(_ funcDecl: FunctionDeclSyntax, initialize: String) -> [CodeBlockItemSyntax] {

  let cache: TokenSyntax = cacheName(funcDecl)
  let arguments: LabeledExprListSyntax = paramsExpr(funcDecl)
  
  return [
    """
    func \(funcDecl.name)\(funcDecl.signature){
      typealias ___C = \(cacheTypeName(funcDecl))
      let params = ___C.params(\(arguments))
      if let result = \(cache)[params] {
        return result
      }
      let r = ___body(\(arguments))
      \(cache)[params] = r
      return r
    }
    """,
    """
    func ___body\(funcDecl.signature)\(funcDecl.body)
    """,
    """
    return \(funcDecl.name)(\(arguments))
    """
  ]
}

func paramsExpr(_ funcDecl: FunctionDeclSyntax) -> LabeledExprListSyntax {
  
  func expr(_ p: FunctionParameterSyntax) -> LabeledExprSyntax? {
    switch (p.firstName.tokenKind, p.firstName, p.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return LabeledExprSyntax(expression: ExprSyntax(stringLiteral: "\(parameterName)"))
    case (_, let firstName, .some(let parameterName)):
      return LabeledExprSyntax(label: firstName.trimmed, colon: ":", expression: ExprSyntax(stringLiteral: "\(parameterName)"))
    case (_, _, .none):
      return nil
    }
  }
  
  return LabeledExprListSyntax {
    for labeldExprSyntax in funcDecl.signature.parameterClause.parameters.compactMap(expr) {
      labeldExprSyntax
    }
  }
}

func tupleTypeElement(_ funcDecl: FunctionDeclSyntax) -> String {
  funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.type) {
    case (.wildcard,_,let type):
      return "\(type)"
    case (_,let firstName,let type):
      return "\(firstName.trimmed): \(type)"
    }
  }.joined(separator: ", ")
}

func cacheTypeName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
  "___Cache"
}

func cacheName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
  "___cache"
}

func returnType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {
  funcDecl.signature.returnClause?.type.trimmed ?? "Void"
}

func maxCount(_ node: AttributeSyntax) -> String? {
  var maxCount: String?
  let arguments = node.arguments?.as(LabeledExprListSyntax.self) ?? []
  for argument in arguments {
    if let label = argument.label?.text, label == "maxCount" {
      if let valueExpr = argument.expression.as(IntegerLiteralExprSyntax.self) {
        maxCount = valueExpr.literal.text
        break
      }
      if argument.expression.is(NilLiteralExprSyntax.self) {
        maxCount = "nil"
      }
    }
  }
  return maxCount ?? (isLRU(node) ? "nil" : nil)
}

func isLRU(_ node: AttributeSyntax) -> Bool {
  node.description.lowercased().contains("lru")
}
