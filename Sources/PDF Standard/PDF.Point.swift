// PDF.Point.swift

extension PDF {
    /// A point in the PDF coordinate system
    ///
    /// Uses top-left origin with y increasing downward.
    /// Automatically transformed to PDF's bottom-left origin at emission.
    public struct Point: Sendable, Hashable {
        /// X coordinate (points from left edge)
        public var x: Double

        /// Y coordinate (points from top edge, increasing downward)
        public var y: Double

        /// Create a point
        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }

        /// Origin (top-left corner)
        public static let zero = Self(x: 0, y: 0)
    }
}

extension PDF.Point {
    /// Offset this point by the given amounts
    public func offset(x dx: Double = 0, y dy: Double = 0) -> Self {
        Self(x: x + dx, y: y + dy)
    }
}
