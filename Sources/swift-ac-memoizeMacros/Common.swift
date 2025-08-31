import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

func functionBodyWithLimit(
  _ parameters: String, _ storage: String, _ maxCount: String?, _ funcDecl: FunctionDeclSyntax
) -> CodeBlockItemSyntax {
  let params = funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return "\(parameterName)"
    case (_, let firstName, .some(let parameterName)):
      return "\(firstName.trimmed): \(parameterName)"
    case (_, _, .none):
      fatalError()
    }
  }.joined(separator: ", ")
  return """
    func \(funcDecl.name)\(funcDecl.signature){
      let maxCount: Int? = \(raw: maxCount ?? "nil")
      let args = \(raw: parameters)(\(raw: params))
      if let result = \(raw: storage)[args] {
        return result
      }
      let r = body(\(raw: params))
      if let maxCount, \(raw: storage).count == maxCount {
        let i = \(raw: storage).startIndex
        \(raw: storage).remove(at: i)
      }
      \(raw: storage)[args] = r
      return r
    }
    func body\(funcDecl.signature)\(funcDecl.body)
    return \(raw: funcDecl.name)(\(raw: params))
    """
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

func cowCache(_ funcDecl: FunctionDeclSyntax, maxCount limit: String?) -> DeclSyntax {
  return """
    enum \(cacheTypeName(funcDecl)): _ComparableMemoizationCacheProtocol {
      @usableFromInline typealias Parameters = (\(raw: tupleTypeElement(funcDecl)))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = CoW
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

func baseCache(_ funcDecl: FunctionDeclSyntax, maxCount limit: String?) -> DeclSyntax {
  return """
    enum \(cacheTypeName(funcDecl)): _ComparableMemoizationProtocol {
      @usableFromInline typealias Parameters = (\(raw: tupleTypeElement(funcDecl)))
      @usableFromInline typealias Return = \(returnType(funcDecl))
      @usableFromInline typealias Instance = Base
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
        .init()
      }
    }
    """
}

func hashCacheN(_ funcDecl: FunctionDeclSyntax) -> DeclSyntax {
  return """
    typealias Params = Pack<\(raw: labelLessTypeElement(funcDecl))>
    typealias Memo = Params.Cache.Standard<\(returnType(funcDecl))>
    """
}

func lruCacheN(_ funcDecl: FunctionDeclSyntax, maxCount limit: String?) -> DeclSyntax {
  return """
    typealias Params = Pack<\(raw: labelLessTypeElement(funcDecl))>
    typealias Memo = Params.Cache.LRU<\(returnType(funcDecl))>
    """
}

func functionBodyWithMutex(_ funcDecl: FunctionDeclSyntax, initialize: String)
  -> [CodeBlockItemSyntax]
{

  let cache: TokenSyntax = cacheName(funcDecl)
  let params = paramsExpr(funcDecl)

  return [
    """
    func \(funcDecl.name)\(funcDecl.signature){
      typealias ___C = \(cacheTypeName(funcDecl))
      let params = ___C.params(\(params))
      if let result = \(cache).withLock({ $0[params] }) {
        return result
      }
      let r = ___body(\(params))
      \(cache).withLock { $0[params] = r }
      return r
    }
    """,
    """
    func ___body\(funcDecl.signature)\(funcDecl.body)
    """,
    """
    return \(raw: funcDecl.name)(\(params))
    """,
  ]
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
    """,
  ]
}

func functionBodyN(_ funcDecl: FunctionDeclSyntax, initialize: String) -> [CodeBlockItemSyntax] {

  let cache: TokenSyntax = cacheName(funcDecl)
  let arguments: LabeledExprListSyntax = paramsExpr(funcDecl)

  let argumentsN: LabeledExprListSyntax = paramsNExpr(funcDecl)

  return [
    """
    func \(funcDecl.name)\(funcDecl.signature){
      if let result = \(cache)[.init(\(argumentsN))] {
        return result
      }
      let r = ___body(\(arguments))
      \(cache)[.init(\(argumentsN))] = r
      return r
    }
    """,
    """
    func ___body\(funcDecl.signature)\(funcDecl.body)
    """,
    """
    return \(funcDecl.name)(\(arguments))
    """,
  ]
}

func functionBodyNN(_ funcDecl: FunctionDeclSyntax, initialize: String) -> [CodeBlockItemSyntax] {

  let cache: TokenSyntax = cacheName(funcDecl)
  let arguments: LabeledExprListSyntax = paramsExpr(funcDecl)

  let argumentsN: LabeledExprListSyntax = paramsNExpr(funcDecl)

  return [
    """
    func \(funcDecl.name)\(funcDecl.signature){
      \(cache)[.init(\(argumentsN)), fallBacking: ___body]
    }
    """,
    """
    func ___body\(funcDecl.signature)\(funcDecl.body)
    """,
    """
    return \(funcDecl.name)(\(arguments))
    """,
  ]
}

func functionBodyWithMutexNN(_ funcDecl: FunctionDeclSyntax, initialize: String)
  -> [CodeBlockItemSyntax]
{

  let cache: TokenSyntax = cacheName(funcDecl)
  return ["\(cache).withLock { \(cache) in"] + functionBodyNN(funcDecl, initialize: initialize) + ["}"]
}

func paramsExpr(_ funcDecl: FunctionDeclSyntax) -> LabeledExprListSyntax {

  func expr(_ p: FunctionParameterSyntax) -> LabeledExprSyntax? {
    switch (p.firstName.tokenKind, p.firstName, p.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return LabeledExprSyntax(expression: ExprSyntax(stringLiteral: "\(parameterName)"))
    case (_, let firstName, .some(let parameterName)):
      return LabeledExprSyntax(
        label: firstName.trimmed, colon: ":",
        expression: ExprSyntax(stringLiteral: "\(parameterName)"))
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

func paramsNExpr(_ funcDecl: FunctionDeclSyntax) -> LabeledExprListSyntax {

  func expr(_ p: FunctionParameterSyntax) -> LabeledExprSyntax? {
    switch (p.firstName.tokenKind, p.firstName, p.parameterName) {
    case (.wildcard, _, .some(let parameterName)):
      return LabeledExprSyntax(expression: ExprSyntax(stringLiteral: "\(parameterName)"))
    case (_, _, .some(let parameterName)):
      return LabeledExprSyntax(expression: ExprSyntax(stringLiteral: "\(parameterName)"))
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
    case (.wildcard, _, let type):
      return "\(type)"
    case (_, let firstName, let type):
      return "\(firstName.trimmed): \(type)"
    }
  }.joined(separator: ", ")
}

func labelLessTypeElement(_ funcDecl: FunctionDeclSyntax) -> String {
  funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.type) {
    case (.wildcard, _, let type):
      return "\(type)"
    case (_, _, let type):
      return "\(type)"
    }
  }.joined(separator: ", ")
}

func fullTypeElement(_ funcDecl: FunctionDeclSyntax) -> String {
  (funcDecl.signature.parameterClause.parameters.map {
    switch ($0.firstName.tokenKind, $0.firstName, $0.type) {
    case (.wildcard, _, let type):
      return "\(type)"
    case (_, _, let type):
      return "\(type)"
    }
  } + ["\(returnType(funcDecl))"]).joined(separator: ", ")
}

func storedCache(_ funcDecl: FunctionDeclSyntax, _ node: AttributeSyntax) -> DeclSyntax {
  let maxCount: String? = maxCount(node)
  if let maxCount {
    return cowCache(funcDecl, maxCount: maxCount)
  } else {
    return hashCache(funcDecl)
  }
}

func cacheTypeName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
  "___MemoizationCache___\(raw: funcDecl.name.text)"
}

func cacheName(_ funcDecl: FunctionDeclSyntax) -> TokenSyntax {
  "\(raw: funcDecl.name.text)_cache"
}

func paramsType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {
  "\(raw: funcDecl.name.text)_parameters"
}

func returnType(_ funcDecl: FunctionDeclSyntax) -> TypeSyntax {
  funcDecl.signature.returnClause?.type.trimmed ?? "Void"
}

func isStaticFunction(_ functionDecl: FunctionDeclSyntax) -> Bool {
  functionDecl.modifiers.contains { $0.name.text == "static" }
}

#if false
  func maxCount(_ node: AttributeSyntax) -> String? {
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
    return maxCount ?? (isLRU(node) ? "Int.max" : nil)
  }

  func isLRU(_ node: AttributeSyntax) -> Bool {
    node.description.lowercased().contains("lru")
  }
#else
  func maxCount(_ node: AttributeSyntax) -> String? {
    for argument in node.arguments?.as(LabeledExprListSyntax.self) ?? [] {
      if let label = argument.label?.text, label == "maxCount" {
        return argument.expression.description
      }
    }
    return nil
  }
#endif
