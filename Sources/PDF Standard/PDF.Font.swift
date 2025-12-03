// PDF.Font.swift

public import ISO_32000

extension PDF {
    public typealias Font = ISO_32000.Font.Standard14
}

extension PDF.Font {
    /// Get the ISO 32000 Font object
    public var isoFont: ISO_32000.Font {
        ISO_32000.Font(self)
    }
}


// MARK: - Text Measurement

extension PDF.Font {
    /// Calculate string width at a specific font size
    ///
    /// - Parameters:
    ///   - text: The text to measure
    ///   - size: Font size in points
    /// - Returns: Width in points
    public func stringWidth(_ text: String, atSize size: Double) -> Double {
        metrics.stringWidth(text, atSize: size)
    }
}
