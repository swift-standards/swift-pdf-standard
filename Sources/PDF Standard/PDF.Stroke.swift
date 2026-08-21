extension PDF {

    public struct Stroke: Sendable, Hashable {

        public var color: PDF.Color

        public var width: PDF.UserSpace.Width

        public init(_ color: PDF.Color, width: PDF.UserSpace.Width = .init(1)) {
            self.color = color
            self.width = width
        }
    }
}
