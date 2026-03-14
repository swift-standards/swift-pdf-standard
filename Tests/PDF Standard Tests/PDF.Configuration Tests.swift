// PDF.Configuration Tests.swift
//
// Unit tests for PDF.Configuration

import Testing
import PDF_Standard

extension PDF.Configuration {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit

extension PDF.Configuration.Test.Unit {

    @Test
    func `default configuration uses A4 paper size`() {
        let config = PDF.Configuration()
        #expect(config.paperSize == .a4)
    }

    @Test
    func `default configuration uses 72 point margins`() {
        let config = PDF.Configuration()
        #expect(config.margins == PDF.UserSpace.EdgeInsets(all: 72))
    }

    @Test
    func `default configuration uses Times font`() {
        let config = PDF.Configuration()
        #expect(config.defaultFont == .times)
    }

    @Test
    func `default configuration uses 12 point font size`() {
        let config = PDF.Configuration()
        #expect(config.defaultFontSize == 12)
    }

    @Test
    func `default configuration uses black color`() {
        let config = PDF.Configuration()
        #expect(config.defaultColor == .black)
    }

    @Test
    func `default configuration uses 1.2 line height`() {
        let config = PDF.Configuration()
        #expect(config.lineHeight == 1.2)
    }

    @Test
    func `default configuration uses version 1.7`() {
        let config = PDF.Configuration()
        #expect(config.version == .v1_7)
    }

    @Test
    func `default configuration has nil info`() {
        let config = PDF.Configuration()
        #expect(config.info == nil)
    }

    @Test
    func `mediaBox equals paperSize`() {
        let config = PDF.Configuration(paperSize: .letter)
        #expect(config.mediaBox == .letter)
    }

    @Test
    func `content area subtracts margins from paper size`() {
        let config = PDF.Configuration(
            paperSize: .letter,
            margins: .init(all: 72)
        )
        let content = config.content
        // Letter is 612x792, minus 72*2=144 on each axis
        #expect(content.width == PDF.UserSpace.Width(612 - 144))
        #expect(content.height == PDF.UserSpace.Height(792 - 144))
    }

    @Test
    func `custom paper size is stored`() {
        let config = PDF.Configuration(paperSize: .legal)
        #expect(config.paperSize == .legal)
    }

    @Test
    func `custom font is stored`() {
        let config = PDF.Configuration(defaultFont: .helvetica)
        #expect(config.defaultFont == .helvetica)
    }

    @Test
    func `custom version is stored`() {
        let config = PDF.Configuration(version: .v2_0)
        #expect(config.version == .v2_0)
    }

    @Test
    func `info with title and author`() {
        let info = ISO_32000.Document.Info(
            title: "Test Document",
            author: "Test Author"
        )
        let config = PDF.Configuration(info: info)
        #expect(config.info?.title == "Test Document")
        #expect(config.info?.author == "Test Author")
    }

    @Test
    func `properties are mutable`() {
        var config = PDF.Configuration()
        config.paperSize = .letter
        config.defaultFont = .courier
        config.version = .v2_0
        #expect(config.paperSize == .letter)
        #expect(config.defaultFont == .courier)
        #expect(config.version == .v2_0)
    }
}

// MARK: - Edge Case

extension PDF.Configuration.Test.EdgeCase {

    @Test
    func `zero margins produce content equal to paper size`() {
        let config = PDF.Configuration(
            paperSize: .a4,
            margins: .zero
        )
        #expect(config.content.width == config.paperSize.width)
        #expect(config.content.height == config.paperSize.height)
    }

    @Test
    func `all paper sizes are available`() {
        let sizes: [PDF.UserSpace.Rectangle] = [.a3, .a4, .a5, .letter, .legal, .tabloid]
        #expect(sizes.count == 6)
    }

    @Test
    func `all PDF versions are available`() {
        let versions = ISO_32000.Version.allCases
        #expect(versions.count == 5)
        #expect(versions.contains(.v1_4))
        #expect(versions.contains(.v1_5))
        #expect(versions.contains(.v1_6))
        #expect(versions.contains(.v1_7))
        #expect(versions.contains(.v2_0))
    }
}
