// PDF.Stroke.swift
// Stroke style for PDF graphics

extension PDF {
    /// Stroke style for PDF graphics.
    ///
    /// Groups stroke-related properties together for cleaner APIs.
    /// Can be extended with additional properties like dash patterns,
    /// cap styles, and join styles per ISO 32000-2:2020, Section 8.4.3.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let stroke = PDF.Stroke(.black, width: 2)
    /// let thinStroke = PDF.Stroke(.red)  // default width of 1
    /// ```
    public struct Stroke: Sendable, Hashable {
        /// The stroke color
        public var color: PDF.Color

        /// The stroke line width
        public var width: PDF.UserSpace.Width

        /// Create a stroke style
        ///
        /// - Parameters:
        ///   - color: The stroke color
        ///   - width: The line width (default: 1 user space unit)
        public init(_ color: PDF.Color, width: PDF.UserSpace.Width = 1) {
            self.color = color
            self.width = width
        }
    }
}
