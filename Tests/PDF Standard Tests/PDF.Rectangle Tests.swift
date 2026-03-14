// PDF.Rectangle Tests.swift
//
// Unit tests for PDF.Rectangle

import Testing
import PDF_Standard

extension PDF.Rectangle {
    @Suite
    struct Test {
        @Suite struct Unit {}
        @Suite struct EdgeCase {}
    }
}

// MARK: - Unit

extension PDF.Rectangle.Test.Unit {

    @Test
    func `init from geometry with fill`() {
        let rect = PDF.Rectangle(.a4, fill: .red)
        #expect(rect.rect == .a4)
        #expect(rect.fill == .red)
        #expect(rect.stroke == nil)
    }

    @Test
    func `init from geometry with stroke`() {
        let stroke = PDF.Stroke(.black, width: .init(2))
        let rect = PDF.Rectangle(.letter, stroke: stroke)
        #expect(rect.rect == .letter)
        #expect(rect.fill == nil)
        #expect(rect.stroke == stroke)
    }

    @Test
    func `init from geometry with fill and stroke`() {
        let stroke = PDF.Stroke(.blue, width: .init(3))
        let rect = PDF.Rectangle(.a4, fill: .green, stroke: stroke)
        #expect(rect.fill == .green)
        #expect(rect.stroke == stroke)
    }

    @Test
    func `init from dimensions`() {
        let rect = PDF.Rectangle(
            x: .init(10),
            y: .init(20),
            width: .init(100),
            height: .init(50),
            fill: .red
        )
        #expect(rect.rect.width == .init(100))
        #expect(rect.rect.height == .init(50))
        #expect(rect.fill == .red)
    }

    @Test
    func `init from dimensions defaults x and y to zero`() {
        let rect = PDF.Rectangle(
            width: .init(200),
            height: .init(100)
        )
        #expect(rect.fill == nil)
        #expect(rect.stroke == nil)
    }

    @Test
    func `conforms to Sendable`() {
        let rect = PDF.Rectangle(.a4, fill: .black)
        let _: any Sendable = rect
    }

    @Test
    func `conforms to Hashable`() {
        let rect1 = PDF.Rectangle(.a4, fill: .red)
        let rect2 = PDF.Rectangle(.a4, fill: .red)
        #expect(rect1 == rect2)
    }

    @Test
    func `properties are mutable`() {
        var rect = PDF.Rectangle(.a4, fill: .red)
        rect.fill = .blue
        rect.stroke = PDF.Stroke(.black)
        #expect(rect.fill == .blue)
        #expect(rect.stroke?.color == .black)
    }
}

// MARK: - UserSpace.Rectangle convenience extensions

extension PDF.Rectangle.Test.Unit {

    @Test
    func `filled convenience creates rectangle with fill color`() {
        let styled = PDF.UserSpace.Rectangle.a4.filled(.red)
        #expect(styled.fill == .red)
        #expect(styled.stroke == nil)
        #expect(styled.rect == .a4)
    }

    @Test
    func `stroked convenience creates rectangle with stroke`() {
        let styled = PDF.UserSpace.Rectangle.letter.stroked(.black)
        #expect(styled.stroke?.color == .black)
        #expect(styled.stroke?.width == .init(1))
        #expect(styled.fill == nil)
    }

    @Test
    func `stroked convenience with custom width`() {
        let styled = PDF.UserSpace.Rectangle.a4.stroked(.blue, width: .init(5))
        #expect(styled.stroke?.color == .blue)
        #expect(styled.stroke?.width == .init(5))
    }

    @Test
    func `styled convenience with both fill and stroke`() {
        let stroke = PDF.Stroke(.black, width: .init(2))
        let styled = PDF.UserSpace.Rectangle.a4.styled(fill: .red, stroke: stroke)
        #expect(styled.fill == .red)
        #expect(styled.stroke == stroke)
    }

    @Test
    func `styled convenience with nil values`() {
        let styled = PDF.UserSpace.Rectangle.a4.styled()
        #expect(styled.fill == nil)
        #expect(styled.stroke == nil)
    }
}

// MARK: - Edge Case

extension PDF.Rectangle.Test.EdgeCase {

    @Test
    func `rectangles with different fills are not equal`() {
        let rect1 = PDF.Rectangle(.a4, fill: .red)
        let rect2 = PDF.Rectangle(.a4, fill: .blue)
        #expect(rect1 != rect2)
    }

    @Test
    func `rectangles with different strokes are not equal`() {
        let rect1 = PDF.Rectangle(.a4, stroke: PDF.Stroke(.black, width: .init(1)))
        let rect2 = PDF.Rectangle(.a4, stroke: PDF.Stroke(.black, width: .init(2)))
        #expect(rect1 != rect2)
    }

    @Test
    func `rectangle with no fill and no stroke`() {
        let rect = PDF.Rectangle(.a4)
        #expect(rect.fill == nil)
        #expect(rect.stroke == nil)
    }
}
