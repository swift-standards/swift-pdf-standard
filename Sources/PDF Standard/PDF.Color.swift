// PDF.Color.swift

extension PDF {
    /// PDF color
    ///
    /// Supports RGB and grayscale color spaces.
    public enum Color: Sendable, Hashable {
        /// RGB color (0-1 range for each component)
        case rgb(r: Double, g: Double, b: Double)

        /// Grayscale color (0 = black, 1 = white)
        case gray(Double)

        // MARK: - Common Colors

        /// Black
        public static let black = Color.gray(0)

        /// White
        public static let white = Color.gray(1)

        /// Red
        public static let red = Color.rgb(r: 1, g: 0, b: 0)

        /// Green
        public static let green = Color.rgb(r: 0, g: 1, b: 0)

        /// Blue
        public static let blue = Color.rgb(r: 0, g: 0, b: 1)

        /// Dark gray (25%)
        public static let darkGray = Color.gray(0.25)

        /// Gray (50%)
        public static let gray50 = Color.gray(0.5)

        /// Light gray (75%)
        public static let lightGray = Color.gray(0.75)
    }
}

// MARK: - Hex Color

extension PDF.Color {
    /// Create color from hex string
    ///
    /// Supports formats: `#RGB`, `#RRGGBB`, `RGB`, `RRGGBB`
    public init?(hex: String) {
        var hexString = hex
        if hexString.hasPrefix("#") {
            hexString.removeFirst()
        }

        let scanner = hexString.unicodeScalars
        var value: UInt64 = 0

        for scalar in scanner {
            value *= 16
            switch scalar {
            case "0"..."9":
                value += UInt64(scalar.value - UnicodeScalar("0").value)
            case "a"..."f":
                value += UInt64(scalar.value - UnicodeScalar("a").value + 10)
            case "A"..."F":
                value += UInt64(scalar.value - UnicodeScalar("A").value + 10)
            default:
                return nil
            }
        }

        switch hexString.count {
        case 3:
            // RGB shorthand
            let r = Double((value >> 8) & 0xF) / 15.0
            let g = Double((value >> 4) & 0xF) / 15.0
            let b = Double(value & 0xF) / 15.0
            self = .rgb(r: r, g: g, b: b)
        case 6:
            // RRGGBB
            let r = Double((value >> 16) & 0xFF) / 255.0
            let g = Double((value >> 8) & 0xFF) / 255.0
            let b = Double(value & 0xFF) / 255.0
            self = .rgb(r: r, g: g, b: b)
        default:
            return nil
        }
    }
}
