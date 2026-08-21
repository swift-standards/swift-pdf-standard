extension PDF {

    public struct Configuration: Sendable {

        public var paperSize: PDF.UserSpace.Rectangle

        public var margins: PDF.UserSpace.Insets

        public var defaultFont: PDF.Font

        public var defaultFontSize: PDF.UserSpace.Size<1>

        public var defaultColor: PDF.Color

        public var lineHeight: Scale<1, Double>

        public var version: ISO_32000.Version

        public var info: ISO_32000.Document.Info?

        public var viewer: ISO_32000.Viewer

        public var outline: Outline

        public init(
            paperSize: PDF.UserSpace.Rectangle = .a4,
            margins: PDF.UserSpace.Insets = .init(all: 72),
            defaultFont: PDF.Font = .times,
            defaultFontSize: PDF.UserSpace.Size<1> = 12,
            defaultColor: PDF.Color = .black,
            lineHeight: Scale<1, Double> = 1.2,
            version: ISO_32000.Version = .v1_7,
            info: ISO_32000.Document.Info? = nil,
            viewer: ISO_32000.Viewer = .init(),
            outline: Outline = .init()
        ) {
            self.paperSize = paperSize
            self.margins = margins
            self.defaultFont = defaultFont
            self.defaultFontSize = defaultFontSize
            self.defaultColor = defaultColor
            self.lineHeight = lineHeight
            self.version = version
            self.info = info
            self.viewer = viewer
            self.outline = outline
        }
    }
}

extension PDF.Configuration {

    public var mediaBox: PDF.UserSpace.Rectangle {
        paperSize
    }

    public var content: PDF.UserSpace.Size<2> {
        .init(
            width: paperSize.width - margins.horizontal,
            height: paperSize.height - margins.vertical
        )
    }
}
