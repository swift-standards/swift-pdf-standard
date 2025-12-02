// PDF.Font Tests.swift

import Testing
@testable import PDF_Standard
import ISO_32000

@Suite
struct `PDF.Font Tests` {

    // MARK: - All Fonts Exist

    @Test(arguments: PDF.Font.allCases)
    func `All fonts exist`(font: PDF.Font) {
        let _ = font.isoFont
    }

    // MARK: - Standard 14 Mapping

    @Test(arguments: [
        (PDF.Font.helvetica, ISO_32000.Font.Standard14.helvetica),
        (.helveticaBold, .helveticaBold),
        (.helveticaOblique, .helveticaOblique),
        (.helveticaBoldOblique, .helveticaBoldOblique)
    ])
    func `Helvetica family maps correctly`(font: PDF.Font, expected: ISO_32000.Font.Standard14) {
        #expect(font.standard14 == expected)
    }

    @Test(arguments: [
        (PDF.Font.times, ISO_32000.Font.Standard14.timesRoman),
        (.timesBold, .timesBold),
        (.timesItalic, .timesItalic),
        (.timesBoldItalic, .timesBoldItalic)
    ])
    func `Times family maps correctly`(font: PDF.Font, expected: ISO_32000.Font.Standard14) {
        #expect(font.standard14 == expected)
    }

    @Test(arguments: [
        (PDF.Font.courier, ISO_32000.Font.Standard14.courier),
        (.courierBold, .courierBold),
        (.courierOblique, .courierOblique),
        (.courierBoldOblique, .courierBoldOblique)
    ])
    func `Courier family maps correctly`(font: PDF.Font, expected: ISO_32000.Font.Standard14) {
        #expect(font.standard14 == expected)
    }

    @Test(arguments: [
        (PDF.Font.symbol, ISO_32000.Font.Standard14.symbol),
        (.zapfDingbats, .zapfDingbats)
    ])
    func `Special fonts map correctly`(font: PDF.Font, expected: ISO_32000.Font.Standard14) {
        #expect(font.standard14 == expected)
    }

    // MARK: - ISO Font Access

    @Test(arguments: PDF.Font.allCases)
    func `IsoFont returns valid font`(font: PDF.Font) {
        let isoFont = font.isoFont
        #expect(isoFont.baseFontName.rawValue == font.standard14.rawValue)
    }

    // MARK: - Metrics Access

    @Test(arguments: PDF.Font.allCases)
    func `Metrics are accessible`(font: PDF.Font) {
        let metrics = font.metrics
        #expect(metrics.glyphWidth(for: "A") > 0)
    }

    @Test(arguments: [
        PDF.Font.helvetica,
        .helveticaBold,
        .times,
        .timesBold,
        .courier
    ])
    func `Metrics have valid ascender and descender`(font: PDF.Font) {
        let metrics = font.metrics
        #expect(metrics.ascender > 0)
        #expect(metrics.descender < 0)
        #expect(metrics.lineHeight > 0)
    }

    @Test
    func `Line height calculation at font size`() {
        let metrics = PDF.Font.helvetica.metrics
        let lineHeight12 = metrics.lineHeight(atSize: 12)
        let lineHeight24 = metrics.lineHeight(atSize: 24)
        #expect(lineHeight24 == lineHeight12 * 2)
    }

    // MARK: - String Width Calculation

    @Test
    func `Calculates string width`() {
        let width = PDF.Font.helvetica.stringWidth("Hello", atSize: 12)
        #expect(width > 0)
    }

    @Test
    func `Empty string has zero width`() {
        let width = PDF.Font.helvetica.stringWidth("", atSize: 12)
        #expect(width == 0)
    }

    @Test
    func `Larger font size produces larger width`() {
        let width12 = PDF.Font.helvetica.stringWidth("Hello", atSize: 12)
        let width24 = PDF.Font.helvetica.stringWidth("Hello", atSize: 24)
        #expect(width24 > width12)
    }

    @Test
    func `Monospaced fonts have consistent character widths`() {
        let courier = PDF.Font.courier
        let widthI = courier.stringWidth("i", atSize: 12)
        let widthM = courier.stringWidth("m", atSize: 12)
        #expect(widthI == widthM)
    }

    @Test
    func `Proportional fonts have varying character widths`() {
        let helvetica = PDF.Font.helvetica
        let widthI = helvetica.stringWidth("i", atSize: 12)
        let widthM = helvetica.stringWidth("m", atSize: 12)
        #expect(widthI < widthM)
    }

    // MARK: - Equality

    @Test
    func `Same fonts are equal`() {
        #expect(PDF.Font.helvetica == PDF.Font.helvetica)
    }

    @Test
    func `Different fonts are not equal`() {
        #expect(PDF.Font.helvetica != PDF.Font.times)
    }

    // MARK: - Hashable

    @Test
    func `Fonts are hashable`() {
        var set: Set<PDF.Font> = []
        for font in PDF.Font.allCases {
            set.insert(font)
        }
        #expect(set.count == PDF.Font.allCases.count)
    }
}
