// PDF_Standard_Tests.swift

import Testing
@testable import PDF_Standard

@Suite("PDF Standard")
struct PDFStandardTests {

    // MARK: - Paper Size Tests

    @Test("A4 paper size")
    func a4Size() {
        let a4 = PDF.PaperSize.a4
        #expect(a4.width > 595 && a4.width < 596)
        #expect(a4.height > 841 && a4.height < 842)
    }

    @Test("Letter paper size")
    func letterSize() {
        let letter = PDF.PaperSize.letter
        #expect(letter.width == 612)
        #expect(letter.height == 792)
    }

    @Test("Landscape orientation")
    func landscape() {
        let portrait = PDF.PaperSize.a4
        let landscape = portrait.landscape
        #expect(landscape.width == portrait.height)
        #expect(landscape.height == portrait.width)
    }

    // MARK: - Edge Insets Tests

    @Test("Standard margins")
    func standardMargins() {
        let margins = PDF.EdgeInsets.standard
        #expect(margins.top == 72)
        #expect(margins.left == 72)
        #expect(margins.bottom == 72)
        #expect(margins.right == 72)
    }

    @Test("Uniform margins")
    func uniformMargins() {
        let margins = PDF.EdgeInsets(all: 36)
        #expect(margins.horizontal == 72)
        #expect(margins.vertical == 72)
    }

    // MARK: - Font Tests

    @Test("Font mapping to Standard 14")
    func fontMapping() {
        #expect(PDF.Font.helvetica.standard14 == .helvetica)
        #expect(PDF.Font.times.standard14 == .timesRoman)
        #expect(PDF.Font.courier.standard14 == .courier)
    }

    @Test("Font string width measurement")
    func fontMeasurement() {
        let width = PDF.Font.helvetica.stringWidth("Hello", atSize: 12)
        #expect(width > 0)
    }

    // MARK: - Color Tests

    @Test("Grayscale colors")
    func grayscaleColors() {
        let black = PDF.Color.black
        let white = PDF.Color.white

        if case .gray(let g) = black {
            #expect(g == 0)
        } else {
            Issue.record("Expected grayscale color")
        }

        if case .gray(let g) = white {
            #expect(g == 1)
        } else {
            Issue.record("Expected grayscale color")
        }
    }

    @Test("Hex color parsing")
    func hexColors() {
        let red = PDF.Color(hex: "#FF0000")
        #expect(red != nil)

        if case .rgb(let r, let g, let b) = red {
            #expect(r == 1)
            #expect(g == 0)
            #expect(b == 0)
        }

        let shorthand = PDF.Color(hex: "#F00")
        #expect(shorthand != nil)
    }

    // MARK: - Point Tests

    @Test("Point offset")
    func pointOffset() {
        let p = PDF.Point(x: 10, y: 20)
        let offset = p.offset(x: 5, y: 10)
        #expect(offset.x == 15)
        #expect(offset.y == 30)
    }

    // MARK: - Document Tests

    @Test("Create simple document")
    func simpleDocument() {
        let doc = PDF.Document(
            page: PDF.Page(
                paperSize: .letter,
                margins: .standard
            ) {
                .text("Hello, World!", at: .init(x: 72, y: 72))
            }
        )

        let bytes = doc.write(compress: false)
        let str = String(decoding: bytes, as: UTF8.self)

        #expect(str.hasPrefix("%PDF-1.7"))
        #expect(str.contains("/Type /Page"))
        #expect(str.contains("%%EOF"))
    }

    @Test("Document with metadata")
    func documentWithMetadata() {
        let doc = PDF.Document(
            page: PDF.Page(paperSize: .a4) {
                .text("Test", at: .init(x: 100, y: 100))
            },
            info: PDF.Info(
                title: "Test Document",
                author: "Swift PDF"
            )
        )

        let bytes = doc.write(compress: false)
        let str = String(decoding: bytes, as: UTF8.self)

        #expect(str.contains("/Title"))
        #expect(str.contains("/Author"))
    }

    @Test("Compressed document")
    func compressedDocument() {
        let doc = PDF.Document(
            page: PDF.Page(paperSize: .a4) {
                PDF.Content.text("This is a longer text that should compress well.", at: .init(x: 72, y: 72))
                PDF.Content.text("Adding more content to ensure compression is applied.", at: .init(x: 72, y: 100))
                PDF.Content.text("The content stream needs to be large enough for compression.", at: .init(x: 72, y: 128))
                PDF.Content.text("ZLIB adds 6 bytes of overhead so small streams may not compress.", at: .init(x: 72, y: 156))
            }
        )

        let bytes = doc.write(compress: true)
        let str = String(decoding: bytes, as: UTF8.self)

        #expect(str.contains("/Filter /FlateDecode"))
    }

    @Test("Coordinate transformation (top-left to bottom-left)")
    func coordinateTransformation() {
        // Y=72 from top on letter (792 height) should become Y=720 in PDF
        let doc = PDF.Document(
            page: PDF.Page(
                paperSize: .letter,
                margins: .zero
            ) {
                .text("Top", at: .init(x: 72, y: 72))
            }
        )

        let bytes = doc.write(compress: false)
        let str = String(decoding: bytes, as: UTF8.self)

        // The text should be positioned at PDF y = 792 - 72 = 720
        #expect(str.contains("720 Td"))
    }
}
