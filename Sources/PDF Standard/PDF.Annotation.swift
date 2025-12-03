// PDF.Annotation.swift

public import ISO_32000

extension PDF {
    /// PDF Annotation with top-left origin coordinates
    public enum Annotation: Sendable {
        /// Link annotation (clickable URL)
        case link(LinkAnnotation)
    }

    /// Link annotation
    public struct LinkAnnotation: Sendable {
        /// Rectangle defining the clickable area (top-left origin coordinates)
        public var rect: Rect

        /// The URI to open when clicked
        public var uri: String

        /// Create a link annotation
        public init(rect: Rect, uri: String) {
            self.rect = rect
            self.uri = uri
        }
    }
}

// MARK: - ISO 32000 Conversion

extension PDF.Annotation {
    /// Convert to ISO 32000 annotation with coordinate transformation
    func toISO(pageHeight: Double) -> ISO_32000.Annotation {
        switch self {
        case .link(let link):
            // Transform from top-left to bottom-left coordinates
            let isoY = pageHeight - link.rect.y - link.rect.height
            let isoRect = ISO_32000.Rectangle(
                x: link.rect.x,
                y: isoY,
                width: link.rect.width,
                height: link.rect.height
            )
            return .link(ISO_32000.LinkAnnotation(rect: isoRect, uri: link.uri))
        }
    }
}
