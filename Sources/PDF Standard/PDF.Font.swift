// PDF.Font.swift

public import ISO_32000

extension PDF {
    /// PDF font selection
    ///
    /// Maps to the Standard 14 fonts guaranteed to be available
    /// in every PDF reader per ISO 32000-1 Section 9.6.2.2.
    public enum Font: Sendable, Hashable, CaseIterable {
        case helvetica
        case helveticaBold
        case helveticaOblique
        case helveticaBoldOblique
        case times
        case timesBold
        case timesItalic
        case timesBoldItalic
        case courier
        case courierBold
        case courierOblique
        case courierBoldOblique
        case symbol
        case zapfDingbats

        /// Maps to canonical ISO_32000.Font.Standard14
        public var standard14: ISO_32000.Font.Standard14 {
            switch self {
            case .helvetica: return .helvetica
            case .helveticaBold: return .helveticaBold
            case .helveticaOblique: return .helveticaOblique
            case .helveticaBoldOblique: return .helveticaBoldOblique
            case .times: return .timesRoman
            case .timesBold: return .timesBold
            case .timesItalic: return .timesItalic
            case .timesBoldItalic: return .timesBoldItalic
            case .courier: return .courier
            case .courierBold: return .courierBold
            case .courierOblique: return .courierOblique
            case .courierBoldOblique: return .courierBoldOblique
            case .symbol: return .symbol
            case .zapfDingbats: return .zapfDingbats
            }
        }

        /// Get the ISO 32000 Font object
        public var isoFont: ISO_32000.Font {
            ISO_32000.Font(standard14)
        }

        /// Font metrics for text measurement
        public var metrics: ISO_32000.Font.Metrics {
            standard14.metrics
        }
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
