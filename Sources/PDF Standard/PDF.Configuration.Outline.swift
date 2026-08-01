// PDF.Configuration.Outline.swift
//
// Document outline (bookmarks) configuration.

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
