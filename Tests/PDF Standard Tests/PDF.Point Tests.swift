// PDF.Point Tests.swift

import Testing
@testable import PDF_Standard

@Suite
struct `PDF.Point Tests` {

    // MARK: - Construction

    @Test
    func `Creates point with coordinates`() {
        let point = PDF.Point(x: 100, y: 200)
        #expect(point.x == 100)
        #expect(point.y == 200)
    }

    @Test
    func `Zero is at origin`() {
        let zero = PDF.Point.zero
        #expect(zero.x == 0)
        #expect(zero.y == 0)
    }

    // MARK: - Offset

    @Test
    func `Offset by x only`() {
        let point = PDF.Point(x: 100, y: 200)
        let offset = point.offset(x: 50)
        #expect(offset.x == 150)
        #expect(offset.y == 200)
    }

    @Test
    func `Offset by y only`() {
        let point = PDF.Point(x: 100, y: 200)
        let offset = point.offset(y: 50)
        #expect(offset.x == 100)
        #expect(offset.y == 250)
    }

    @Test
    func `Offset by both x and y`() {
        let point = PDF.Point(x: 100, y: 200)
        let offset = point.offset(x: 50, y: 30)
        #expect(offset.x == 150)
        #expect(offset.y == 230)
    }

    @Test
    func `Offset with negative values`() {
        let point = PDF.Point(x: 100, y: 200)
        let offset = point.offset(x: -50, y: -100)
        #expect(offset.x == 50)
        #expect(offset.y == 100)
    }

    @Test
    func `Offset does not mutate original`() {
        let point = PDF.Point(x: 100, y: 200)
        let _ = point.offset(x: 50, y: 50)
        #expect(point.x == 100)
        #expect(point.y == 200)
    }

    // MARK: - Equality

    @Test
    func `Same points are equal`() {
        let a = PDF.Point(x: 100, y: 200)
        let b = PDF.Point(x: 100, y: 200)
        #expect(a == b)
    }

    @Test
    func `Different points are not equal`() {
        let a = PDF.Point(x: 100, y: 200)
        let b = PDF.Point(x: 100, y: 201)
        #expect(a != b)
    }

    // MARK: - Hashable

    @Test
    func `Points are hashable`() {
        var set: Set<PDF.Point> = []
        set.insert(.zero)
        set.insert(PDF.Point(x: 100, y: 200))
        #expect(set.count == 2)

        set.insert(.zero)
        #expect(set.count == 2)
    }
}
