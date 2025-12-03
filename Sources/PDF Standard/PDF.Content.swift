//
//  File.swift
//  swift-pdf-standard
//
//  Created by Coen ten Thije Boonkkamp on 02/12/2025.
//

extension PDF {
    /// Page content
    public struct Content: Sendable {
        /// Content operations
        public var operations: [Operation]
        
        /// Create empty content
        public init() {
            self.operations = []
        }
        
        /// Create content with operations
        public init(operations: [Operation]) {
            self.operations = operations
        }
    }
}


extension PDF.Content {
    /// Add text at a position
    public static func text(
        _ text: String,
        at position: PDF.Point,
        font: PDF.Font = .helvetica,
        size: Double = 12,
        color: PDF.Color = .black
    ) -> PDF.Content {
        PDF.Content(operations: [
            .text(PDF.Content.Text.Operation(
                text: text,
                position: position,
                font: font,
                size: size,
                color: color
            ))
        ])
    }
}
