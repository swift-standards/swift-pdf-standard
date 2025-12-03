//
//  File.swift
//  swift-pdf-standard
//
//  Created by Coen ten Thije Boonkkamp on 02/12/2025.
//

extension PDF.Content {
    /// Result builder for page content
    @resultBuilder
    public struct Builder {
        public static func buildExpression(_ expression: PDF.Content) -> PDF.Content {
            expression
        }

        public static func buildBlock(_ components: PDF.Content...) -> PDF.Content {
            PDF.Content(operations: components.flatMap { $0.operations })
        }

        public static func buildOptional(_ component: PDF.Content?) -> PDF.Content {
            component ?? PDF.Content()
        }

        public static func buildEither(first component: PDF.Content) -> PDF.Content {
            component
        }

        public static func buildEither(second component: PDF.Content) -> PDF.Content {
            component
        }

        public static func buildArray(_ components: [PDF.Content]) -> PDF.Content {
            PDF.Content(operations: components.flatMap { $0.operations })
        }
    }
}
