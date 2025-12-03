//
//  File.swift
//  swift-pdf-standard
//
//  Created by Coen ten Thije Boonkkamp on 02/12/2025.
//



extension PDF.Content.Text {
    /// Text operation
    public struct Operation: Sendable {
        public var text: String
        public var position: PDF.Point
        public var font: PDF.Font
        public var size: Double
        public var color: PDF.Color
        
        public init(
            text: String,
            position: PDF.Point,
            font: PDF.Font,
            size: Double,
            color: PDF.Color
        ) {
            self.text = text
            self.position = position
            self.font = font
            self.size = size
            self.color = color
        }
    }
}
