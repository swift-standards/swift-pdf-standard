//
//  File.swift
//  swift-pdf-standard
//
//  Created by Coen ten Thije Boonkkamp on 02/12/2025.
//

extension PDF.Content {
    /// Content operation
    public enum Operation: Sendable {
        case text(PDF.Content.Text.Operation)
        case graphics(PDF.Content.Graphics.Operation)
    }
}
