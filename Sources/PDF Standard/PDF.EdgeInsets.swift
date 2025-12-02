// PDF.EdgeInsets.swift

extension PDF {
    /// Edge insets (margins) for page content
    ///
    /// All values are in points (1/72 inch).
    public struct EdgeInsets: Sendable, Hashable {
        /// Top margin
        public var top: Double

        /// Left margin
        public var left: Double

        /// Bottom margin
        public var bottom: Double

        /// Right margin
        public var right: Double

        /// Create edge insets
        public init(top: Double, left: Double, bottom: Double, right: Double) {
            self.top = top
            self.left = left
            self.bottom = bottom
            self.right = right
        }

        /// Create uniform edge insets
        public init(all value: Double) {
            self.top = value
            self.left = value
            self.bottom = value
            self.right = value
        }

        /// Create symmetric edge insets
        public init(horizontal: Double, vertical: Double) {
            self.top = vertical
            self.left = horizontal
            self.bottom = vertical
            self.right = horizontal
        }

        /// No margins
        public static let zero = Self(top: 0, left: 0, bottom: 0, right: 0)

        /// Standard 1-inch margins (72 points)
        public static let standard = Self(all: 72)

        /// Half-inch margins (36 points)
        public static let half = Self(all: 36)
    }
}

extension PDF.EdgeInsets {
    /// Total horizontal inset (left + right)
    public var horizontal: Double { left + right }

    /// Total vertical inset (top + bottom)
    public var vertical: Double { top + bottom }
}
