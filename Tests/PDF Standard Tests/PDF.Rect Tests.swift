// PDF.Rect Tests.swift

import Testing
@testable import PDF_Standard

@Suite
struct `PDF.Rect Tests` {

    // MARK: - Construction from Origin and Size

    @Test
    func `Creates rect from origin and size`() {
        let origin = PDF.Point(x: 10, y: 20)
        let size = PDF.Size(width: 100, height: 200)
        let rect = PDF.Rect(origin: origin, size: size)

        #expect(rect.origin == origin)
        #expect(rect.size == size)
    }

    // MARK: - Construction from Coordinates

    @Test
    func `Creates rect from coordinates`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)

        #expect(rect.x == 10)
        #expect(rect.y == 20)
        #expect(rect.width == 100)
        #expect(rect.height == 200)
    }

    // MARK: - Accessors

    @Test
    func `X returns origin x`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.x == rect.origin.x)
    }

    @Test
    func `Y returns origin y`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.y == rect.origin.y)
    }

    @Test
    func `Width returns size width`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.width == rect.size.width)
    }

    @Test
    func `Height returns size height`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.height == rect.size.height)
    }

    // MARK: - Edge Calculations

    @Test
    func `MinX is origin x`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.minX == 10)
    }

    @Test
    func `MaxX is origin x plus width`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.maxX == 110)
    }

    @Test
    func `MinY is origin y`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.minY == 20)
    }

    @Test
    func `MaxY is origin y plus height`() {
        let rect = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(rect.maxY == 220)
    }

    // MARK: - Equality

    @Test
    func `Same rects are equal`() {
        let a = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        let b = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        #expect(a == b)
    }

    @Test
    func `Rects with same values but different construction are equal`() {
        let a = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        let b = PDF.Rect(
            origin: PDF.Point(x: 10, y: 20),
            size: PDF.Size(width: 100, height: 200)
        )
        #expect(a == b)
    }

    @Test
    func `Different rects are not equal`() {
        let a = PDF.Rect(x: 10, y: 20, width: 100, height: 200)
        let b = PDF.Rect(x: 10, y: 20, width: 101, height: 200)
        #expect(a != b)
    }

    // MARK: - Hashable

    @Test
    func `Rects are hashable`() {
        var set: Set<PDF.Rect> = []
        set.insert(PDF.Rect(x: 0, y: 0, width: 100, height: 100))
        set.insert(PDF.Rect(x: 10, y: 20, width: 100, height: 200))
        #expect(set.count == 2)
    }
}
