// PDF.Stroke Tests.swift
//
// Unit tests for PDF.Stroke

import Testing
import PDF_Standard

extension PDF.Stroke {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit

extension PDF.Stroke.Test.Unit {

    @Test
    func `init with color defaults width to 1`() {
        let stroke = PDF.Stroke(.black)
        #expect(stroke.color == .black)
        #expect(stroke.width == .init(1))
    }

    @Test
    func `init with color and custom width`() {
        let stroke = PDF.Stroke(.red, width: .init(3))
        #expect(stroke.color == .red)
        #expect(stroke.width == .init(3))
    }

    @Test
    func `conforms to Sendable`() {
        let stroke = PDF.Stroke(.black)
        let _: any Sendable = stroke
    }

    @Test
    func `conforms to Hashable`() {
        let stroke1 = PDF.Stroke(.black, width: .init(2))
        let stroke2 = PDF.Stroke(.black, width: .init(2))
        #expect(stroke1 == stroke2)
    }

    @Test
    func `properties are mutable`() {
        var stroke = PDF.Stroke(.black)
        stroke.color = .red
        stroke.width = .init(5)
        #expect(stroke.color == .red)
        #expect(stroke.width == .init(5))
    }

    @Test
    func `different colors produce different strokes`() {
        let black = PDF.Stroke(.black)
        let red = PDF.Stroke(.red)
        #expect(black != red)
    }

    @Test
    func `different widths produce different strokes`() {
        let thin = PDF.Stroke(.black, width: .init(1))
        let thick = PDF.Stroke(.black, width: .init(5))
        #expect(thin != thick)
    }

    @Test
    func `RGB color stroke`() {
        let stroke = PDF.Stroke(.rgb(r: 0.5, g: 0.3, b: 0.7))
        #expect(stroke.color == .rgb(r: 0.5, g: 0.3, b: 0.7))
    }

    @Test
    func `gray color stroke`() {
        let stroke = PDF.Stroke(.gray(0.5))
        #expect(stroke.color == .gray(0.5))
    }
}

// MARK: - Edge Case

extension PDF.Stroke.Test.EdgeCase {

    @Test
    func `stroke with all named colors`() {
        let colors: [PDF.Color] = [.black, .white, .red, .green, .blue]
        for color in colors {
            let stroke = PDF.Stroke(color)
            #expect(stroke.color == color)
        }
    }
}
