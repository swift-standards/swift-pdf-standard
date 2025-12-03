// PDF.Page Tests.swift

import Testing
@testable import PDF_Standard
import ISO_32000

@Suite
struct `PDF.Page Tests` {

    // MARK: - Construction

    @Test
    func `Creates page with paper size and margins`() {
        let page = PDF.Page(
            paperSize: .letter,
            margins: .standard,
            content: PDF.Content()
        )

        #expect(page.paperSize == .letter)
        #expect(page.margins == .standard)
    }

    @Test
    func `Creates page with builder syntax`() {
        let page = PDF.Page(paperSize: .a4) {
            PDF.Content.text("Hello", at: PDF.Point(x: 72, y: 72))
        }

        #expect(page.paperSize == .a4)
        #expect(page.content.operations.count == 1)
    }

    @Test
    func `Default paper size is A4`() {
        let page = PDF.Page(content: PDF.Content())
        #expect(page.paperSize == .a4)
    }

    @Test
    func `Default margins are standard (1 inch)`() {
        let page = PDF.Page(content: PDF.Content())
        #expect(page.margins == .standard)
    }

    // MARK: - Content Area

    @Test
    func `Content width accounts for margins`() {
        let page = PDF.Page(
            paperSize: .letter,
            margins: PDF.EdgeInsets(all: 72),
            content: PDF.Content()
        )

        #expect(page.contentWidth == 612 - 72 - 72)
    }

    @Test
    func `Content height accounts for margins`() {
        let page = PDF.Page(
            paperSize: .letter,
            margins: PDF.EdgeInsets(all: 72),
            content: PDF.Content()
        )

        #expect(page.contentHeight == 792 - 72 - 72)
    }

    @Test
    func `Content rect has correct origin`() {
        let page = PDF.Page(
            paperSize: .letter,
            margins: PDF.EdgeInsets(top: 50, left: 40, bottom: 30, right: 20),
            content: PDF.Content()
        )

        #expect(page.contentRect.x == 40)
        #expect(page.contentRect.y == 50)
        #expect(page.contentRect.width == 612 - 40 - 20)
        #expect(page.contentRect.height == 792 - 50 - 30)
    }

    // MARK: - ISO 32000 Conversion

    @Test
    func `Converts to ISO 32000 page`() {
        let page = PDF.Page(
            paperSize: .letter,
            content: PDF.Content()
        )

        let isoPage = ISO_32000.Page(page)

        #expect(isoPage.mediaBox.width == 612)
        #expect(isoPage.mediaBox.height == 792)
    }

    @Test
    func `Includes fonts in resources when text is present`() {
        let page = PDF.Page(paperSize: .letter) {
            PDF.Content.text("Hello", at: .zero, font: .helvetica, size: 12)
        }

        let isoPage = ISO_32000.Page(page)

        #expect(isoPage.resources.fonts.count == 1)
    }
}

// MARK: - PDF.Content Tests

@Suite
struct `PDF.Content Tests` {

    @Test
    func `Creates empty content`() {
        let content = PDF.Content()
        #expect(content.operations.isEmpty)
    }

    @Test
    func `Creates content with operations`() {
        let content = PDF.Content(operations: [
            .text(PDF.Content.Text.Operation(
                text: "Hello",
                position: .zero,
                font: .helvetica,
                size: 12,
                color: .black
            ))
        ])

        #expect(content.operations.count == 1)
    }

    @Test
    func `Text factory creates text operation`() {
        let content = PDF.Content.text(
            "Hello",
            at: PDF.Point(x: 100, y: 200),
            font: .times,
            size: 14,
            color: .blue
        )

        #expect(content.operations.count == 1)
        if case .text(let textOp) = content.operations[0] {
            #expect(textOp.text == "Hello")
            #expect(textOp.position.x == 100)
            #expect(textOp.position.y == 200)
            #expect(textOp.font == .times)
            #expect(textOp.size == 14)
            #expect(textOp.color == .blue)
        } else {
            Issue.record("Expected text operation")
        }
    }

    @Test
    func `Text factory uses defaults`() {
        let content = PDF.Content.text("Hi", at: .zero)

        if case .text(let textOp) = content.operations[0] {
            #expect(textOp.font == .helvetica)
            #expect(textOp.size == 12)
            #expect(textOp.color == .black)
        }
    }
}

// MARK: - PDF.Content.Text.Operation Tests

@Suite
struct `PDF.Content.Text.Operation Tests` {

    @Test
    func `Creates text operation with all properties`() {
        let op = PDF.Content.Text.Operation(
            text: "Sample",
            position: PDF.Point(x: 50, y: 100),
            font: .courierBold,
            size: 18,
            color: .red
        )

        #expect(op.text == "Sample")
        #expect(op.position.x == 50)
        #expect(op.position.y == 100)
        #expect(op.font == .courierBold)
        #expect(op.size == 18)
        #expect(op.color == .red)
    }
}

// MARK: - PDF.GraphicsOperation Tests

@Suite
struct `PDF.GraphicsOperation Tests` {

    @Test
    func `Creates line operation`() {
        let op = PDF.GraphicsOperation.line(
            from: PDF.Point(x: 0, y: 0),
            to: PDF.Point(x: 100, y: 100),
            color: .black,
            width: 1.0
        )

        if case .line(let from, let to, let color, let width) = op {
            #expect(from.x == 0)
            #expect(to.x == 100)
            #expect(color == .black)
            #expect(width == 1.0)
        } else {
            Issue.record("Expected line operation")
        }
    }

    @Test
    func `Creates rectangle operation with fill`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 50)
        let op = PDF.GraphicsOperation.rectangle(
            rect,
            fill: .blue,
            stroke: nil,
            strokeWidth: 0
        )

        if case .rectangle(let r, let fill, let stroke, _) = op {
            #expect(r == rect)
            #expect(fill == .blue)
            #expect(stroke == nil)
        } else {
            Issue.record("Expected rectangle operation")
        }
    }

    @Test
    func `Creates rectangle operation with stroke`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 50)
        let op = PDF.GraphicsOperation.rectangle(
            rect,
            fill: nil,
            stroke: .red,
            strokeWidth: 2.0
        )

        if case .rectangle(_, let fill, let stroke, let width) = op {
            #expect(fill == nil)
            #expect(stroke == .red)
            #expect(width == 2.0)
        } else {
            Issue.record("Expected rectangle operation")
        }
    }
}

// MARK: - Content Builder Tests

@Suite
struct `PDF.ContentBuilder Tests` {

    @Test
    func `Combines multiple content blocks`() {
        let page = PDF.Page(paperSize: .letter) {
            PDF.Content.text("Line 1", at: PDF.Point(x: 72, y: 72))
            PDF.Content.text("Line 2", at: PDF.Point(x: 72, y: 100))
        }

        #expect(page.content.operations.count == 2)
    }

    @Test
    func `Handles optional content`() {
        let showOptional = true
        let page = PDF.Page(paperSize: .letter) {
            PDF.Content.text("Always", at: .zero)
            if showOptional {
                PDF.Content.text("Sometimes", at: PDF.Point(x: 0, y: 20))
            }
        }

        #expect(page.content.operations.count == 2)
    }
}

// MARK: - Page Builder Tests

@Suite
struct `PDF.Page.Builder Tests` {

    @Test
    func `Builds single page`() {
        let doc = PDF.Document {
            PDF.Page(paperSize: .letter, content: PDF.Content())
        }

        #expect(doc.pages.count == 1)
    }

    @Test
    func `Builds multiple pages`() {
        let doc = PDF.Document {
            PDF.Page(paperSize: .letter, content: PDF.Content())
            PDF.Page(paperSize: .a4, content: PDF.Content())
            PDF.Page(paperSize: .legal, content: PDF.Content())
        }

        #expect(doc.pages.count == 3)
    }

    @Test
    func `Handles conditional pages`() {
        let includePage = true
        let doc = PDF.Document {
            PDF.Page(paperSize: .letter, content: PDF.Content())
            if includePage {
                PDF.Page(paperSize: .a4, content: PDF.Content())
            }
        }

        #expect(doc.pages.count == 2)
    }

    @Test
    func `Handles for loops`() {
        let doc = PDF.Document {
            for _ in 0..<5 {
                PDF.Page(paperSize: .letter, content: PDF.Content())
            }
        }

        #expect(doc.pages.count == 5)
    }
}
