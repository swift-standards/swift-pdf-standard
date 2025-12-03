//
//  File.swift
//  swift-pdf-standard
//
//  Created by Coen ten Thije Boonkkamp on 02/12/2025.
//



extension PDF.Content.Graphics {
    /// Graphics operation
    public enum Operation: Sendable {
        case line(
            from: PDF.Point,
            to: PDF.Point,
            color: PDF.Color,
            width: Double
        )
        case rectangle(
            PDF.Rect,
            fill: PDF.Color?,
            stroke: PDF.Color?,
            strokeWidth: Double
        )
    }
}
