// PDF.PaperSize.swift

extension PDF {
    /// Standard paper sizes
    ///
    /// All sizes are in points (1/72 inch).
    public struct PaperSize: Sendable, Hashable {
        /// Width in points
        public var width: Double

        /// Height in points
        public var height: Double

        /// Create a custom paper size
        public init(width: Double, height: Double) {
            self.width = width
            self.height = height
        }

        /// Size as PDF.Size
        public var size: Size {
            Size(width: width, height: height)
        }
    }
}

// MARK: - Standard Sizes

extension PDF.PaperSize {
    /// A4 (210mm × 297mm)
    public static let a4 = Self(width: 595.276, height: 841.890)

    /// A3 (297mm × 420mm)
    public static let a3 = Self(width: 841.890, height: 1190.551)

    /// A5 (148mm × 210mm)
    public static let a5 = Self(width: 419.528, height: 595.276)

    /// US Letter (8.5" × 11")
    public static let letter = Self(width: 612, height: 792)

    /// US Legal (8.5" × 14")
    public static let legal = Self(width: 612, height: 1008)

    /// US Tabloid (11" × 17")
    public static let tabloid = Self(width: 792, height: 1224)
}

// MARK: - Orientation

extension PDF.PaperSize {
    /// Return the landscape version of this paper size
    public var landscape: Self {
        Self(width: height, height: width)
    }

    /// Return the portrait version of this paper size
    public var portrait: Self {
        width > height ? Self(width: height, height: width) : self
    }
}
