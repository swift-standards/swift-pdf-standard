//
//  PDF.Rectangle.swift
//  swift-pdf-standard
//
//  Created by Coen ten Thije Boonkkamp on 05/12/2025.
//

extension PDF {
    /// A styled rectangle view.
    ///
    /// This is a renderable rectangle with fill and stroke styling.
    /// For the pure geometry type, use `PDF.UserSpace.Rectangle`.
    ///
    /// ## Example
    ///
    /// ```swift
    /// PDF.Rectangle(width: 100, height: 50, fill: .red)
    /// PDF.Rectangle(width: 100, height: 50, fill: .blue, stroke: .init(.black, width: 2))
    /// ```
    public struct Rectangle: Sendable, Hashable {

        /// The underlying rectangle geometry
        public var rect: PDF.UserSpace.Rectangle

        /// Fill color (nil for no fill)
        public var fill: PDF.Color?

        /// Stroke style (nil for no stroke)
        public var stroke: PDF.Stroke?

        /// Create a styled rectangle from geometry
        public init(
            _ rect: PDF.UserSpace.Rectangle,
            fill: PDF.Color? = nil,
            stroke: PDF.Stroke? = nil
        ) {
            self.rect = rect
            self.fill = fill
            self.stroke = stroke
        }

        /// Create from dimensions
        public init(
            x: PDF.UserSpace.X = 0,
            y: PDF.UserSpace.Y = 0,
            width: PDF.UserSpace.Width,
            height: PDF.UserSpace.Height,
            fill: PDF.Color? = nil,
            stroke: PDF.Stroke? = nil
        ) {
            self.rect = PDF.UserSpace.Rectangle(
                x: x,
                y: y,
                width: width,
                height: height
            )
            self.fill = fill
            self.stroke = stroke
        }
    }
}

extension PDF.UserSpace.Rectangle {
    /// Create a styled PDF rectangle with fill color
    public func filled(_ color: PDF.Color) -> PDF.Rectangle {
        PDF.Rectangle(self, fill: color)
    }

    /// Create a styled PDF rectangle with stroke
    public func stroked(_ color: PDF.Color, width: PDF.UserSpace.Width = 1) -> PDF.Rectangle {
        PDF.Rectangle(self, stroke: .init(color, width: width))
    }

    /// Create a styled PDF rectangle with fill and stroke
    public func styled(
        fill: PDF.Color? = nil,
        stroke: PDF.Stroke? = nil
    ) -> PDF.Rectangle {
        PDF.Rectangle(self, fill: fill, stroke: stroke)
    }
}
