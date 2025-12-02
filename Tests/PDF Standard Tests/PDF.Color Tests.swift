// PDF.Color Tests.swift

import Testing
@testable import PDF_Standard

@Suite
struct `PDF.Color Tests` {

    // MARK: - Static Colors

    @Test
    func `Black is gray 0`() {
        if case .gray(let value) = PDF.Color.black {
            #expect(value == 0)
        } else {
            Issue.record("Expected gray color")
        }
    }

    @Test
    func `White is gray 1`() {
        if case .gray(let value) = PDF.Color.white {
            #expect(value == 1)
        } else {
            Issue.record("Expected gray color")
        }
    }

    @Test
    func `Red is RGB 1,0,0`() {
        if case .rgb(let r, let g, let b) = PDF.Color.red {
            #expect(r == 1)
            #expect(g == 0)
            #expect(b == 0)
        } else {
            Issue.record("Expected RGB color")
        }
    }

    @Test
    func `Green is RGB 0,1,0`() {
        if case .rgb(let r, let g, let b) = PDF.Color.green {
            #expect(r == 0)
            #expect(g == 1)
            #expect(b == 0)
        } else {
            Issue.record("Expected RGB color")
        }
    }

    @Test
    func `Blue is RGB 0,0,1`() {
        if case .rgb(let r, let g, let b) = PDF.Color.blue {
            #expect(r == 0)
            #expect(g == 0)
            #expect(b == 1)
        } else {
            Issue.record("Expected RGB color")
        }
    }

    @Test(arguments: [
        (PDF.Color.darkGray, 0.25),
        (.gray50, 0.5),
        (.lightGray, 0.75)
    ])
    func `Gray shades have correct values`(color: PDF.Color, expected: Double) {
        if case .gray(let value) = color {
            #expect(value == expected)
        } else {
            Issue.record("Expected gray color")
        }
    }

    // MARK: - Hex Parsing (6-digit)

    @Test(arguments: [
        ("#FF0000", 1.0, 0.0, 0.0),
        ("#00FF00", 0.0, 1.0, 0.0),
        ("#0000FF", 0.0, 0.0, 1.0),
        ("#FFFFFF", 1.0, 1.0, 1.0),
        ("#000000", 0.0, 0.0, 0.0)
    ])
    func `Parses 6-digit hex colors`(hex: String, r: Double, g: Double, b: Double) {
        guard let color = PDF.Color(hex: hex) else {
            Issue.record("Failed to parse hex: \(hex)")
            return
        }
        if case .rgb(let cr, let cg, let cb) = color {
            #expect(abs(cr - r) < 0.01)
            #expect(abs(cg - g) < 0.01)
            #expect(abs(cb - b) < 0.01)
        } else {
            Issue.record("Expected RGB color")
        }
    }

    @Test
    func `Parses hex without hash prefix`() {
        guard let color = PDF.Color(hex: "FF0000") else {
            Issue.record("Failed to parse hex without #")
            return
        }
        if case .rgb(let r, _, _) = color {
            #expect(r == 1.0)
        }
    }

    @Test
    func `Parses lowercase hex`() {
        guard let color = PDF.Color(hex: "#ff0000") else {
            Issue.record("Failed to parse lowercase hex")
            return
        }
        if case .rgb(let r, _, _) = color {
            #expect(r == 1.0)
        }
    }

    // MARK: - Hex Parsing (3-digit shorthand)

    @Test(arguments: [
        ("#F00", 1.0, 0.0, 0.0),
        ("#0F0", 0.0, 1.0, 0.0),
        ("#00F", 0.0, 0.0, 1.0),
        ("#FFF", 1.0, 1.0, 1.0),
        ("#000", 0.0, 0.0, 0.0)
    ])
    func `Parses 3-digit hex shorthand`(hex: String, r: Double, g: Double, b: Double) {
        guard let color = PDF.Color(hex: hex) else {
            Issue.record("Failed to parse hex: \(hex)")
            return
        }
        if case .rgb(let cr, let cg, let cb) = color {
            #expect(abs(cr - r) < 0.01)
            #expect(abs(cg - g) < 0.01)
            #expect(abs(cb - b) < 0.01)
        } else {
            Issue.record("Expected RGB color")
        }
    }

    // MARK: - Invalid Hex

    @Test(arguments: [
        "#GGG",     // Invalid characters
        "#GGGGGG",  // Invalid characters
        "#12345",   // Wrong length (5)
        "#1234567", // Wrong length (7)
        ""          // Empty
    ])
    func `Returns nil for invalid hex`(hex: String) {
        #expect(PDF.Color(hex: hex) == nil)
    }

    // MARK: - Equality

    @Test
    func `Same colors are equal`() {
        #expect(PDF.Color.black == PDF.Color.black)
        #expect(PDF.Color.rgb(r: 0.5, g: 0.5, b: 0.5) == PDF.Color.rgb(r: 0.5, g: 0.5, b: 0.5))
    }

    @Test
    func `Different colors are not equal`() {
        #expect(PDF.Color.black != PDF.Color.white)
        #expect(PDF.Color.red != PDF.Color.blue)
    }

    @Test
    func `Gray and RGB are not equal even with same visual value`() {
        #expect(PDF.Color.black != PDF.Color.rgb(r: 0, g: 0, b: 0))
    }

    // MARK: - Hashable

    @Test
    func `Colors are hashable`() {
        var set: Set<PDF.Color> = []
        set.insert(.black)
        set.insert(.white)
        set.insert(.red)
        #expect(set.count == 3)

        set.insert(.black)
        #expect(set.count == 3)
    }
}
