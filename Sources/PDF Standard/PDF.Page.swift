// PDF.Page.swift

public import ISO_32000

extension PDF {
    /// PDF page with top-left origin coordinate system
    public struct Page: Sendable {
        /// Paper size
        public var paperSize: PaperSize

        /// Page margins
        public var margins: EdgeInsets

        /// Page content
        public var content: Content

        /// Create a page
        public init(
            paperSize: PaperSize = .a4,
            margins: EdgeInsets = .standard,
            content: Content
        ) {
            self.paperSize = paperSize
            self.margins = margins
            self.content = content
        }

        /// Create a page using a builder
        public init(
            paperSize: PaperSize = .a4,
            margins: EdgeInsets = .standard,
            @ContentBuilder _ build: () -> Content
        ) {
            self.paperSize = paperSize
            self.margins = margins
            self.content = build()
        }

        /// Available width for content (paper width minus margins)
        public var contentWidth: Double {
            paperSize.width - margins.left - margins.right
        }

        /// Available height for content (paper height minus margins)
        public var contentHeight: Double {
            paperSize.height - margins.top - margins.bottom
        }

        /// Content area rectangle
        public var contentRect: Rect {
            Rect(
                x: margins.left,
                y: margins.top,
                width: contentWidth,
                height: contentHeight
            )
        }
    }
}

// MARK: - Page Content

extension PDF {
    /// Page content
    public struct Content: Sendable {
        /// Content operations
        public var operations: [Operation]

        /// Create empty content
        public init() {
            self.operations = []
        }

        /// Create content with operations
        public init(operations: [Operation]) {
            self.operations = operations
        }
    }

    /// Content operation
    public enum Operation: Sendable {
        case text(TextOperation)
        case graphics(GraphicsOperation)
    }

    /// Text operation
    public struct TextOperation: Sendable {
        public var text: String
        public var position: Point
        public var font: Font
        public var size: Double
        public var color: Color

        public init(text: String, position: Point, font: Font, size: Double, color: Color) {
            self.text = text
            self.position = position
            self.font = font
            self.size = size
            self.color = color
        }
    }

    /// Graphics operation
    public enum GraphicsOperation: Sendable {
        case line(from: Point, to: Point, color: Color, width: Double)
        case rectangle(Rect, fill: Color?, stroke: Color?, strokeWidth: Double)
    }
}

// MARK: - Content Builder

extension PDF {
    /// Result builder for page content
    @resultBuilder
    public struct ContentBuilder {
        public static func buildExpression(_ expression: Content) -> Content {
            expression
        }

        public static func buildBlock(_ components: Content...) -> Content {
            Content(operations: components.flatMap { $0.operations })
        }

        public static func buildOptional(_ component: Content?) -> Content {
            component ?? Content()
        }

        public static func buildEither(first component: Content) -> Content {
            component
        }

        public static func buildEither(second component: Content) -> Content {
            component
        }

        public static func buildArray(_ components: [Content]) -> Content {
            Content(operations: components.flatMap { $0.operations })
        }
    }
}

// MARK: - Text Content

extension PDF.Content {
    /// Add text at a position
    public static func text(
        _ text: String,
        at position: PDF.Point,
        font: PDF.Font = .helvetica,
        size: Double = 12,
        color: PDF.Color = .black
    ) -> PDF.Content {
        PDF.Content(operations: [
            .text(PDF.TextOperation(
                text: text,
                position: position,
                font: font,
                size: size,
                color: color
            ))
        ])
    }
}

// MARK: - Conversion to ISO 32000

extension PDF.Page {
    /// Convert to ISO 32000 Page
    func toISOPage() -> ISO_32000.Page {
        // Collect all fonts used
        var fontsUsed: Set<PDF.Font> = []
        for op in content.operations {
            if case .text(let textOp) = op {
                fontsUsed.insert(textOp.font)
            }
        }

        // Build resources
        var fontResources: [ISO_32000.COS.Name: ISO_32000.Font] = [:]
        for font in fontsUsed {
            let isoFont = font.isoFont
            fontResources[isoFont.resourceName] = isoFont
        }

        // Build content stream
        let contentStream = ISO_32000.ContentStream { builder in
            for op in content.operations {
                switch op {
                case .text(let textOp):
                    // Transform from top-left to bottom-left coordinates
                    let pdfY = paperSize.height - textOp.position.y

                    builder.beginText()

                    // Set color
                    switch textOp.color {
                    case .gray(let g):
                        builder.setFillColorGray(g)
                    case .rgb(let r, let g, let b):
                        builder.setFillColorRGB(r: r, g: g, b: b)
                    }

                    builder.setFont(textOp.font.isoFont, size: textOp.size)
                    builder.moveText(x: textOp.position.x, y: pdfY)
                    builder.showText(textOp.text)
                    builder.endText()

                case .graphics(let graphicsOp):
                    switch graphicsOp {
                    case .line(let from, let to, let color, let width):
                        let pdfFromY = paperSize.height - from.y
                        let pdfToY = paperSize.height - to.y

                        switch color {
                        case .gray(let g):
                            builder.setStrokeColorGray(g)
                        case .rgb(let r, let g, let b):
                            builder.setStrokeColorRGB(r: r, g: g, b: b)
                        }

                        builder.setLineWidth(width)
                        builder.moveTo(x: from.x, y: pdfFromY)
                        builder.lineTo(x: to.x, y: pdfToY)
                        builder.stroke()

                    case .rectangle(let rect, let fill, let stroke, let strokeWidth):
                        // Transform Y coordinate
                        let pdfY = paperSize.height - rect.y - rect.height

                        if let fill = fill {
                            switch fill {
                            case .gray(let g):
                                builder.setFillColorGray(g)
                            case .rgb(let r, let g, let b):
                                builder.setFillColorRGB(r: r, g: g, b: b)
                            }
                        }

                        if let stroke = stroke {
                            switch stroke {
                            case .gray(let g):
                                builder.setStrokeColorGray(g)
                            case .rgb(let r, let g, let b):
                                builder.setStrokeColorRGB(r: r, g: g, b: b)
                            }
                            builder.setLineWidth(strokeWidth)
                        }

                        builder.rectangle(x: rect.x, y: pdfY, width: rect.width, height: rect.height)

                        if fill != nil && stroke != nil {
                            builder.fillAndStroke()
                        } else if fill != nil {
                            builder.fill()
                        } else if stroke != nil {
                            builder.stroke()
                        }
                    }
                }
            }
        }

        return ISO_32000.Page(
            mediaBox: ISO_32000.Rectangle(
                x: 0, y: 0,
                width: paperSize.width,
                height: paperSize.height
            ),
            content: contentStream,
            resources: ISO_32000.Resources(fonts: fontResources)
        )
    }
}
