//
//  File.swift
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
    /// PDF.Rectangle(width: 100, height: 50, fill: .blue, stroke: .black, strokeWidth: 2)
    /// ```
    public struct Rectangle: Sendable, Hashable {

        /// The underlying rectangle geometry
        public var rect: PDF.UserSpace.Rectangle

        /// Fill color (nil for no fill)
        public var fill: PDF.Color?

        /// Stroke color (nil for no stroke)
        public var stroke: PDF.Color?

        /// Stroke width
        public var strokeWidth: PDF.UserSpace.Unit

        /// Create a styled rectangle from geometry
        public init(
            _ rect: PDF.UserSpace.Rectangle,
            fill: PDF.Color? = nil,
            stroke: PDF.Color? = nil,
            strokeWidth: PDF.UserSpace.Unit = 1
        ) {
            self.rect = rect
            self.fill = fill
            self.stroke = stroke
            self.strokeWidth = strokeWidth
        }

        /// Create from dimensions
        public init(
            x: PDF.UserSpace.Unit = 0,
            y: PDF.UserSpace.Unit = 0,
            width: PDF.UserSpace.Unit,
            height: PDF.UserSpace.Unit,
            fill: PDF.Color? = nil,
            stroke: PDF.Color? = nil,
            strokeWidth: PDF.UserSpace.Unit = 1
        ) {
            self.rect = PDF.UserSpace.Rectangle(
                x: .init(x),
                y: .init(y),
                width: .init(width),
                height: .init(height)
            )
            self.fill = fill
            self.stroke = stroke
            self.strokeWidth = strokeWidth
        }
    }
}

extension Geometry.Rectangle where Scalar == PDF.UserSpace.Unit {
    /// Create a styled PDF rectangle with fill color
    public func filled(_ color: PDF.Color) -> PDF.Rectangle {
        PDF.Rectangle(
            PDF.UserSpace.Rectangle(llx: llx, lly: lly, urx: urx, ury: ury),
            fill: color
        )
    }

    /// Create a styled PDF rectangle with stroke
    public func stroked(_ color: PDF.Color, width: PDF.UserSpace.Unit = 1) -> PDF.Rectangle {
        PDF.Rectangle(
            PDF.UserSpace.Rectangle(llx: llx, lly: lly, urx: urx, ury: ury),
            stroke: color,
            strokeWidth: width
        )
    }

    /// Create a styled PDF rectangle with fill and stroke
    public func styled(
        fill: PDF.Color? = nil,
        stroke: PDF.Color? = nil,
        strokeWidth: PDF.UserSpace.Unit = 1
    ) -> PDF.Rectangle {
        PDF.Rectangle(
            PDF.UserSpace.Rectangle(llx: llx, lly: lly, urx: urx, ury: ury),
            fill: fill,
            stroke: stroke,
            strokeWidth: strokeWidth
        )
    }
}
