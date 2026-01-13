//
//  RemoteLocalizedStringMacro.swift
//  RemoteLocalizationMacros
//
//  Created by Prachi Gauriar on 1/13/26.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct RemoteLocalizedStringMacro: ExpressionMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> ExprSyntax {
        guard
            let firstArgument = node.arguments.first,
            let stringLiteral = firstArgument.expression.as(StringLiteralExprSyntax.self),
            stringLiteral.segments.count == 1,
            case .stringSegment(let stringSegment) = stringLiteral.segments.first
        else {
            throw RemoteLocalizedStringMacroError.requiresStringLiteral
        }

        let keyString = stringSegment.content.text

        // Build the arguments for localizedString call
        var argumentsArray: [LabeledExprSyntax] = []

        // First argument: String.LocalizationValue from the original string literal
        argumentsArray.append(
            LabeledExprSyntax(
                expression: ExprSyntax(StringLiteralExprSyntax(content: keyString)),
                trailingComma: .commaToken()
            )
        )

        // Second argument: key parameter
        argumentsArray.append(
            LabeledExprSyntax(
                label: .identifier("key"),
                colon: .colonToken(),
                expression: ExprSyntax(StringLiteralExprSyntax(content: keyString)),
                trailingComma: .commaToken()
            )
        )

        // Third argument: bundle parameter - use #bundle if not provided, otherwise use provided value
        let bundleArgument = node.arguments.first { $0.label?.text == "bundle" }
        let bundleExpression: ExprSyntax

        if let bundleArgument = bundleArgument {
            // Use the explicitly provided bundle argument
            bundleExpression = bundleArgument.expression
        } else {
            // Default to #bundle
            bundleExpression = ExprSyntax(
                MacroExpansionExprSyntax(
                    macroName: .identifier("bundle"),
                    leftParen: .leftParenToken(),
                    arguments: LabeledExprListSyntax([]),
                    rightParen: .rightParenToken()
                )
            )
        }

        argumentsArray.append(
            LabeledExprSyntax(
                label: .identifier("bundle"),
                colon: .colonToken(),
                expression: bundleExpression
            )
        )

        let arguments = LabeledExprListSyntax(argumentsArray)

        return ExprSyntax(
            FunctionCallExprSyntax(
                calledExpression: DeclReferenceExprSyntax(baseName: .identifier("remoteLocalizedString")),
                leftParen: .leftParenToken(),
                arguments: arguments,
                rightParen: .rightParenToken()
            )
        )
    }
}
