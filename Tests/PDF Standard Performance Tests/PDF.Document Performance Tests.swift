// PDF.Document Performance Tests.swift
//
// Performance tests for PDF document generation

import Testing
import PDF_Standard

@Suite(.serialized)
struct PDFDocumentPerformance {

    // MARK: - Configuration Construction

    @Test(.timed(iterations: 1000, warmup: 100))
    func `Configuration default construction`() {
        let _ = PDF.Configuration()
    }

    @Test(.timed(iterations: 1000, warmup: 100))
    func `Configuration with all custom parameters`() {
        let _ = PDF.Configuration(
            paperSize: .letter,
            margins: .init(all: 36),
            defaultFont: .helvetica,
            defaultFontSize: 14,
            defaultColor: .blue,
            lineHeight: 1.5,
            version: .v2_0,
            info: ISO_32000.Document.Info(
                title: "Performance Test",
                author: "Test",
                creator: "swift-pdf-standard"
            ),
            viewer: ISO_32000.Viewer(),
            outline: PDF.Configuration.Outline(openToLevel: 3, flags: [.bold, .italic])
        )
    }

    @Test(.timed(iterations: 1000, warmup: 100))
    func `Configuration content area computation`() {
        let config = PDF.Configuration(
            paperSize: .a4,
            margins: .init(all: 72)
        )
        let _ = config.content
    }

    // MARK: - Rectangle Construction

    @Test(.timed(iterations: 1000, warmup: 100))
    func `Rectangle from geometry with fill`() {
        let _ = PDF.Rectangle(.a4, fill: .red)
    }

    @Test(.timed(iterations: 1000, warmup: 100))
    func `Rectangle from dimensions with fill and stroke`() {
        let _ = PDF.Rectangle(
            x: .init(10),
            y: .init(20),
            width: .init(100),
            height: .init(50),
            fill: .blue,
            stroke: PDF.Stroke(.black, width: .init(2))
        )
    }

    // MARK: - Stroke Construction

    @Test(.timed(iterations: 1000, warmup: 100))
    func `Stroke construction`() {
        let _ = PDF.Stroke(.black, width: .init(2))
    }

    // MARK: - Document Generation

    @Test(.timed(iterations: 100, warmup: 10))
    func `single page document generation`() {
        let document = PDF.Document(
            info: PDF.Document.Info(title: "Perf Test"),
            pages: [
                PDF.Page(
                    mediaBox: .letter,
                    content: PDF.ContentStream { builder in
                        builder.beginText()
                        builder.setFont(PDF.Font.helvetica, size: 12)
                        builder.moveText(dx: .init(72), dy: .init(700))
                        builder.showText("Performance test document")
                        builder.endText()
                    },
                    resources: PDF.Resources(fonts: [
                        PDF.Font.helvetica.resourceName: PDF.Font.helvetica
                    ])
                )
            ]
        )
        let _ = document.bytes
    }

    @Test(.timed(iterations: 50, warmup: 5))
    func `multi page document generation`() {
        let pages = (0..<10).map { i in
            PDF.Page(
                mediaBox: .a4,
                content: PDF.ContentStream { builder in
                    builder.beginText()
                    builder.setFont(PDF.Font.helvetica, size: 12)
                    builder.moveText(dx: .init(72), dy: .init(750))
                    builder.showText("Page \(i + 1) of performance test document")
                    builder.endText()
                },
                resources: PDF.Resources(fonts: [
                    PDF.Font.helvetica.resourceName: PDF.Font.helvetica
                ])
            )
        }
        let document = PDF.Document(
            info: PDF.Document.Info(title: "Multi-Page Perf Test"),
            pages: pages
        )
        let _ = document.bytes
    }

    @Test(.timed(iterations: 20, warmup: 5))
    func `document with all standard 14 fonts`() {
        var fonts: [PDF.COS.Name: PDF.Font] = [:]
        var contentBuilder = PDF.ContentStream.Builder()
        contentBuilder.beginText()

        var dy: PDF.UserSpace.Dy = .init(700)
        for pdfFont in PDF.Font.standard14 {
            fonts[pdfFont.resourceName] = pdfFont
            contentBuilder.setFont(pdfFont, size: 12)
            contentBuilder.moveText(dx: .init(72), dy: dy)
            contentBuilder.showText("The quick brown fox jumps over the lazy dog.")
            dy = .init(-20)
            contentBuilder.moveText(dx: .init(-72), dy: .init(0))
        }

        contentBuilder.endText()

        let document = PDF.Document(
            pages: [
                PDF.Page(
                    mediaBox: .letter,
                    content: PDF.ContentStream(data: contentBuilder.data),
                    resources: PDF.Resources(fonts: fonts)
                )
            ]
        )
        let _ = document.bytes
    }

    // MARK: - UserSpace.Rectangle Convenience Methods

    @Test(.timed(iterations: 1000, warmup: 100))
    func `filled convenience method`() {
        let _ = PDF.UserSpace.Rectangle.a4.filled(.red)
    }

    @Test(.timed(iterations: 1000, warmup: 100))
    func `stroked convenience method`() {
        let _ = PDF.UserSpace.Rectangle.letter.stroked(.black, width: .init(2))
    }

    @Test(.timed(iterations: 1000, warmup: 100))
    func `styled convenience method`() {
        let stroke = PDF.Stroke(.black, width: .init(1))
        let _ = PDF.UserSpace.Rectangle.a4.styled(fill: .blue, stroke: stroke)
    }
}
