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

        /// Link annotations
        public var annotations: [Annotation]

        /// Create a page
        public init(
            paperSize: PaperSize = .a4,
            margins: EdgeInsets = .standard,
            content: Content,
            annotations: [Annotation] = []
        ) {
            self.paperSize = paperSize
            self.margins = margins
            self.content = content
            self.annotations = annotations
        }

        /// Create a page using a builder
        public init(
            paperSize: PaperSize = .a4,
            margins: EdgeInsets = .standard,
            annotations: [Annotation] = [],
            @PDF.Content.Builder _ build: () -> Content
        ) {
            self.paperSize = paperSize
            self.margins = margins
            self.content = build()
            self.annotations = annotations
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

extension ISO_32000.Page {
    /// Create from a high-level PDF page
    public init(_ pdf: PDF.Page) {
        // Collect all fonts used
        var fontsUsed: Set<PDF.Font> = []
        for op in pdf.content.operations {
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
            for op in pdf.content.operations {
                switch op {
                case .text(let textOp):
                    // Transform from top-left to bottom-left coordinates
                    let pdfY = pdf.paperSize.height - textOp.position.y

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
                        let pdfFromY = pdf.paperSize.height - from.y
                        let pdfToY = pdf.paperSize.height - to.y

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
                        let pdfY = pdf.paperSize.height - rect.y - rect.height

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

        // Convert annotations
        let isoAnnotations = pdf.annotations.map { $0.toISO(pageHeight: pdf.paperSize.height) }

        self.init(
            mediaBox: ISO_32000.Rectangle(
                x: 0, y: 0,
                width: pdf.paperSize.width,
                height: pdf.paperSize.height
            ),
            content: contentStream,
            resources: ISO_32000.Resources(fonts: fontResources),
            annotations: isoAnnotations
        )
    }
}
