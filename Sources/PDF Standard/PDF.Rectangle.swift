extension PDF {

    public struct Rectangle: Sendable, Hashable {

        public var rect: PDF.UserSpace.Rectangle

        public var fill: PDF.Color?

        public var stroke: PDF.Stroke?

        public init(
            _ rect: PDF.UserSpace.Rectangle,
            fill: PDF.Color? = nil,
            stroke: PDF.Stroke? = nil
        ) {
            self.rect = rect
            self.fill = fill
            self.stroke = stroke
        }

        public init(
            x: PDF.UserSpace.X = .init(0),
            y: PDF.UserSpace.Y = .init(0),
            width: PDF.UserSpace.Width,
            height: PDF.UserSpace.Height,
            fill: PDF.Color? = nil,
            stroke: PDF.Stroke? = nil
        ) {
            self.rect = PDF.UserSpace.Rectangle(
                x: x,
                y: y,
                width: width,
                height: height
            )
            self.fill = fill
            self.stroke = stroke
        }
    }
}

extension PDF.UserSpace.Rectangle {

    public func filled(_ color: PDF.Color) -> PDF.Rectangle {
        PDF.Rectangle(self, fill: color)
    }

    public func stroked(_ color: PDF.Color, width: PDF.UserSpace.Width = .init(1)) -> PDF.Rectangle
    {
        PDF.Rectangle(self, stroke: .init(color, width: width))
    }

    public func styled(
        fill: PDF.Color? = nil,
        stroke: PDF.Stroke? = nil
    ) -> PDF.Rectangle {
        PDF.Rectangle(self, fill: fill, stroke: stroke)
    }
}
