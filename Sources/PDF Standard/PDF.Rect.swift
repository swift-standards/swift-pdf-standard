// PDF.Rect.swift

extension PDF {
    /// A rectangle in the PDF coordinate system
    ///
    /// Origin is at top-left, y increases downward.
    public struct Rect: Sendable, Hashable {
        /// Origin (top-left corner of rectangle)
        public var origin: Point

        /// Size of the rectangle
        public var size: Size

        /// Create a rectangle
        public init(origin: Point, size: Size) {
            self.origin = origin
            self.size = size
        }

        /// Create a rectangle from coordinates
        public init(x: Double, y: Double, width: Double, height: Double) {
            self.origin = Point(x: x, y: y)
            self.size = Size(width: width, height: height)
        }

        /// X coordinate of origin
        public var x: Double { origin.x }

        /// Y coordinate of origin
        public var y: Double { origin.y }

        /// Width
        public var width: Double { size.width }

        /// Height
        public var height: Double { size.height }

        /// Minimum X (left edge)
        public var minX: Double { origin.x }

        /// Maximum X (right edge)
        public var maxX: Double { origin.x + size.width }

        /// Minimum Y (top edge)
        public var minY: Double { origin.y }

        /// Maximum Y (bottom edge)
        public var maxY: Double { origin.y + size.height }
    }
}
