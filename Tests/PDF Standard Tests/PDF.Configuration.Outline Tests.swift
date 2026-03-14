// PDF.Configuration.Outline Tests.swift
//
// Unit tests for PDF.Configuration.Outline

import Testing
import PDF_Standard

extension PDF.Configuration.Outline {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit

extension PDF.Configuration.Outline.Test.Unit {

    @Test
    func `default outline opens to level 1`() {
        let outline = PDF.Configuration.Outline()
        #expect(outline.openToLevel == 1)
    }

    @Test
    func `default outline has nil color`() {
        let outline = PDF.Configuration.Outline()
        #expect(outline.color == nil)
    }

    @Test
    func `default outline has empty flags`() {
        let outline = PDF.Configuration.Outline()
        #expect(outline.flags == [])
    }

    @Test
    func `custom openToLevel is stored`() {
        let outline = PDF.Configuration.Outline(openToLevel: 3)
        #expect(outline.openToLevel == 3)
    }

    @Test
    func `bold flag is stored`() {
        let outline = PDF.Configuration.Outline(flags: .bold)
        #expect(outline.flags.contains(.bold))
    }

    @Test
    func `italic flag is stored`() {
        let outline = PDF.Configuration.Outline(flags: .italic)
        #expect(outline.flags.contains(.italic))
    }

    @Test
    func `combined bold and italic flags`() {
        let outline = PDF.Configuration.Outline(flags: [.bold, .italic])
        #expect(outline.flags.contains(.bold))
        #expect(outline.flags.contains(.italic))
    }

    @Test
    func `properties are mutable`() {
        var outline = PDF.Configuration.Outline()
        outline.openToLevel = 5
        outline.flags = .bold
        #expect(outline.openToLevel == 5)
        #expect(outline.flags == .bold)
    }
}

// MARK: - Edge Case

extension PDF.Configuration.Outline.Test.EdgeCase {

    @Test
    func `openToLevel zero collapses all levels`() {
        let outline = PDF.Configuration.Outline(openToLevel: 0)
        #expect(outline.openToLevel == 0)
    }
}
