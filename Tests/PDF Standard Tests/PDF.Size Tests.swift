// PDF.Size Tests.swift

import Testing
@testable import PDF_Standard

@Suite
struct `PDF.Size Tests` {

    // MARK: - Construction

    @Test
    func `Creates size with dimensions`() {
        let size = PDF.Size(width: 100, height: 200)
        #expect(size.width == 100)
        #expect(size.height == 200)
    }

    @Test
    func `Zero has zero dimensions`() {
        let zero = PDF.Size.zero
        #expect(zero.width == 0)
        #expect(zero.height == 0)
    }

    // MARK: - Equality

    @Test
    func `Same sizes are equal`() {
        let a = PDF.Size(width: 100, height: 200)
        let b = PDF.Size(width: 100, height: 200)
        #expect(a == b)
    }

    @Test
    func `Different sizes are not equal`() {
        let a = PDF.Size(width: 100, height: 200)
        let b = PDF.Size(width: 100, height: 201)
        #expect(a != b)
    }

    // MARK: - Hashable

    @Test
    func `Sizes are hashable`() {
        var set: Set<PDF.Size> = []
        set.insert(.zero)
        set.insert(PDF.Size(width: 100, height: 200))
        #expect(set.count == 2)
    }
}
