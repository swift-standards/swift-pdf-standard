// PDF.Configuration.swift
//
// Shared configuration for PDF rendering.

extension PDF {
    /// Shared configuration for PDF rendering.
    ///
    /// This configuration is shared across all PDF rendering methods (direct, HTML, etc.)
    /// and provides a single source of truth for common settings.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var config = PDF.Configuration()
    /// config.paperSize = .letter
    /// config.margins = .init(all: 72)  // 1 inch margins
    /// config.defaultFont = .helvetica
    /// config.viewer.displayDocTitle = true
    /// ```
    public struct Configuration: Sendable {
        // MARK: - Layout

        /// Paper size (default: A4)
        public var paperSize: PDF.UserSpace.Rectangle

        /// Page margins (default: 72 points / 1 inch on all sides)
        public var margins: PDF.UserSpace.EdgeInsets

        // MARK: - Typography

        /// Default font (default: Times)
        public var defaultFont: PDF.Font

        /// Default font size in points (default: 12)
        public var defaultFontSize: PDF.UserSpace.Size<1>

        /// Default text color (default: black)
        public var defaultColor: PDF.Color

        /// Line height multiplier (default: 1.2)
        public var lineHeight: Double

        // MARK: - Document

        /// PDF version (default: 1.7)
        public var version: ISO_32000.Version

        /// Document metadata (title, author, etc.)
        public var info: ISO_32000.Document.Info?

        /// Viewer preferences
        public var viewer: ISO_32000.Viewer

        /// Document outline (bookmarks) settings
        public var outline: Outline

        // MARK: - Initialization

        public init(
            paperSize: PDF.UserSpace.Rectangle = .a4,
            margins: PDF.UserSpace.EdgeInsets = .init(all: 72),
            defaultFont: PDF.Font = .times,
            defaultFontSize: PDF.UserSpace.Size<1> = 12,
            defaultColor: PDF.Color = .black,
            lineHeight: Double = 1.2,
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

        // MARK: - Computed Properties

        /// Media box (same as paper size)
        public var mediaBox: PDF.UserSpace.Rectangle {
            paperSize
        }

        /// Content area size (paper size minus margins)
        public var content: PDF.UserSpace.Size<2> {
            .init(
                width: paperSize.width - margins.horizontal,
                height: paperSize.height - margins.vertical
            )
        }
    }
}

// MARK: - Configuration.Outline

extension PDF.Configuration {
    /// Document outline (bookmarks) configuration.
    public struct Outline: Sendable {
        /// Maximum heading level to expand by default.
        ///
        /// Controls which outline items are expanded when the PDF is first opened:
        /// - `1`: Only top-level items expanded (default)
        /// - `2`: Top two levels expanded
        /// - `0`: All levels collapsed
        public var openToLevel: Int

        /// Color for outline items (nil uses viewer default)
        public var color: ISO_32000.DeviceRGB?

        /// Text style flags for outline items
        public var flags: ISO_32000.Outline.ItemFlags

        public init(
            openToLevel: Int = 1,
            color: ISO_32000.DeviceRGB? = nil,
            flags: ISO_32000.Outline.ItemFlags = []
        ) {
            self.openToLevel = openToLevel
            self.color = color
            self.flags = flags
        }
    }
}
