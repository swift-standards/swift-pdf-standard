// PDF.Size.swift

extension PDF {
    /// A size in the PDF coordinate system
    public struct Size: Sendable, Hashable {
        /// Width in points
        public var width: Double

        /// Height in points
        public var height: Double

        /// Create a size
        public init(width: Double, height: Double) {
            self.width = width
            self.height = height
        }

        /// Zero size
        public static let zero = Self(width: 0, height: 0)
    }
}
