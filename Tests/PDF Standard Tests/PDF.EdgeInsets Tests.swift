// PDF.EdgeInsets Tests.swift

import Testing
@testable import PDF_Standard

@Suite
struct `PDF.EdgeInsets Tests` {

    // MARK: - Individual Insets

    @Test
    func `Creates individual insets`() {
        let insets = PDF.EdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        #expect(insets.top == 10)
        #expect(insets.left == 20)
        #expect(insets.bottom == 30)
        #expect(insets.right == 40)
    }

    // MARK: - Uniform Insets

    @Test
    func `Creates uniform insets`() {
        let insets = PDF.EdgeInsets(all: 50)
        #expect(insets.top == 50)
        #expect(insets.left == 50)
        #expect(insets.bottom == 50)
        #expect(insets.right == 50)
    }

    // MARK: - Symmetric Insets

    @Test
    func `Creates symmetric insets`() {
        let insets = PDF.EdgeInsets(horizontal: 20, vertical: 30)
        #expect(insets.top == 30)
        #expect(insets.left == 20)
        #expect(insets.bottom == 30)
        #expect(insets.right == 20)
    }

    // MARK: - Static Values

    @Test
    func `Zero insets are all zero`() {
        let zero = PDF.EdgeInsets.zero
        #expect(zero.top == 0)
        #expect(zero.left == 0)
        #expect(zero.bottom == 0)
        #expect(zero.right == 0)
    }

    @Test
    func `Standard insets are 72 points (1 inch)`() {
        let standard = PDF.EdgeInsets.standard
        #expect(standard.top == 72)
        #expect(standard.left == 72)
        #expect(standard.bottom == 72)
        #expect(standard.right == 72)
    }

    @Test
    func `Half insets are 36 points (0.5 inch)`() {
        let half = PDF.EdgeInsets.half
        #expect(half.top == 36)
        #expect(half.left == 36)
        #expect(half.bottom == 36)
        #expect(half.right == 36)
    }

    // MARK: - Computed Properties

    @Test
    func `Horizontal returns left plus right`() {
        let insets = PDF.EdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        #expect(insets.horizontal == 60)
    }

    @Test
    func `Vertical returns top plus bottom`() {
        let insets = PDF.EdgeInsets(top: 10, left: 20, bottom: 30, right: 40)
        #expect(insets.vertical == 40)
    }

    // MARK: - Equality

    @Test
    func `Same insets are equal`() {
        let a = PDF.EdgeInsets(all: 50)
        let b = PDF.EdgeInsets(top: 50, left: 50, bottom: 50, right: 50)
        #expect(a == b)
    }

    @Test
    func `Different insets are not equal`() {
        #expect(PDF.EdgeInsets.zero != PDF.EdgeInsets.standard)
    }

    // MARK: - Hashable

    @Test
    func `Edge insets are hashable`() {
        var set: Set<PDF.EdgeInsets> = []
        set.insert(.zero)
        set.insert(.standard)
        set.insert(.half)
        #expect(set.count == 3)
    }
}
