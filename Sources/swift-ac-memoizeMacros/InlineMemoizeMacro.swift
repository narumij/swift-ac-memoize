import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
@_spi(Testing) import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros

public struct InlineMemoizeMacro: BodyMacro {

  public static func expansion(
    of node: AttributeSyntax,
    providingBodyFor declaration: some DeclSyntaxProtocol & WithOptionalCodeBlockSyntax,
    in context: some MacroExpansionContext
  ) throws -> [CodeBlockItemSyntax] {

    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
      return []
    }

    if let maxCount = maxCount(node) {
      return inlineBodyLRU(funcDecl, maxCount: maxCount)
    } else {
      return inlineBodyStandard(funcDecl)
    }
  }
}

func inlineBodyLRU(_ funcDecl: FunctionDeclSyntax, maxCount: String?) -> [CodeBlockItemSyntax] {
  [
    """
    let \(cacheName(funcDecl)): MemoizeCache<\(raw: fullTypeElement(funcDecl))>.LRU = .init(maxCount: \(raw: maxCount ?? "Int.max"))
    """
  ] +
  functionBodyNN(funcDecl, initialize: "")
}

func inlineBodyStandard(_ funcDecl: FunctionDeclSyntax) -> [CodeBlockItemSyntax] {
  [
    """
    let \(cacheName(funcDecl)): MemoizeCache<\(raw: fullTypeElement(funcDecl))>.Standard = .init()
    """
  ] +
  functionBodyNN(funcDecl, initialize: "\(cacheTypeName(funcDecl)).Parameters")
}
