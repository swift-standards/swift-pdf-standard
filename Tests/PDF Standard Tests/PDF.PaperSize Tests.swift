// PDF.PaperSize Tests.swift

import Testing
@testable import PDF_Standard

@Suite
struct `PDF.PaperSize Tests` {

    // MARK: - Standard Sizes

    @Test
    func `Letter size is 8.5 x 11 inches`() {
        let letter = PDF.PaperSize.letter
        #expect(letter.width == 612)   // 8.5 * 72
        #expect(letter.height == 792)  // 11 * 72
    }

    @Test
    func `Legal size is 8.5 x 14 inches`() {
        let legal = PDF.PaperSize.legal
        #expect(legal.width == 612)    // 8.5 * 72
        #expect(legal.height == 1008)  // 14 * 72
    }

    @Test
    func `Tabloid size is 11 x 17 inches`() {
        let tabloid = PDF.PaperSize.tabloid
        #expect(tabloid.width == 792)   // 11 * 72
        #expect(tabloid.height == 1224) // 17 * 72
    }

    @Test
    func `A4 size is 210 x 297 mm`() {
        let a4 = PDF.PaperSize.a4
        #expect(abs(a4.width - 595.276) < 0.001)
        #expect(abs(a4.height - 841.890) < 0.001)
    }

    @Test
    func `A3 size is 297 x 420 mm`() {
        let a3 = PDF.PaperSize.a3
        #expect(abs(a3.width - 841.890) < 0.001)
        #expect(abs(a3.height - 1190.551) < 0.001)
    }

    @Test
    func `A5 size is 148 x 210 mm`() {
        let a5 = PDF.PaperSize.a5
        #expect(abs(a5.width - 419.528) < 0.001)
        #expect(abs(a5.height - 595.276) < 0.001)
    }

    // MARK: - Custom Size

    @Test
    func `Creates custom paper size`() {
        let custom = PDF.PaperSize(width: 400, height: 600)
        #expect(custom.width == 400)
        #expect(custom.height == 600)
    }

    // MARK: - Size Property

    @Test
    func `Returns PDF Size`() {
        let letter = PDF.PaperSize.letter
        let size = letter.size
        #expect(size.width == 612)
        #expect(size.height == 792)
    }

    // MARK: - Landscape Orientation

    @Test
    func `Landscape swaps width and height`() {
        let letter = PDF.PaperSize.letter
        let landscape = letter.landscape
        #expect(landscape.width == 792)
        #expect(landscape.height == 612)
    }

    @Test
    func `Landscape of A4`() {
        let a4 = PDF.PaperSize.a4
        let landscape = a4.landscape
        #expect(abs(landscape.width - 841.890) < 0.001)
        #expect(abs(landscape.height - 595.276) < 0.001)
    }

    // MARK: - Portrait Orientation

    @Test
    func `Portrait of portrait returns same`() {
        let letter = PDF.PaperSize.letter
        let portrait = letter.portrait
        #expect(portrait.width == letter.width)
        #expect(portrait.height == letter.height)
    }

    @Test
    func `Portrait of landscape returns portrait`() {
        let landscape = PDF.PaperSize.letter.landscape
        let portrait = landscape.portrait
        #expect(portrait.width == 612)
        #expect(portrait.height == 792)
    }

    // MARK: - Equality

    @Test
    func `Same sizes are equal`() {
        #expect(PDF.PaperSize.letter == PDF.PaperSize.letter)
        #expect(PDF.PaperSize(width: 100, height: 200) == PDF.PaperSize(width: 100, height: 200))
    }

    @Test
    func `Different sizes are not equal`() {
        #expect(PDF.PaperSize.letter != PDF.PaperSize.legal)
        #expect(PDF.PaperSize.letter != PDF.PaperSize.letter.landscape)
    }

    // MARK: - Hashable

    @Test
    func `Paper sizes are hashable`() {
        var set: Set<PDF.PaperSize> = []
        set.insert(.letter)
        set.insert(.legal)
        set.insert(.a4)
        #expect(set.count == 3)

        set.insert(.letter)
        #expect(set.count == 3)
    }
}
