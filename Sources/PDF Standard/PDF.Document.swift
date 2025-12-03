// PDF.Document.swift

public import ISO_32000
import ISO_32000_Flate

extension PDF {
    /// High-level PDF document builder
    ///
    /// Provides an ergonomic API for creating PDF documents with
    /// top-left origin coordinates (matching HTML/CSS mental model).
    public struct Document: Sendable {
        /// Document pages
        public var pages: [Page]

        /// Document metadata
        public var info: Info?

        /// PDF version
        public var version: ISO_32000.Version

        /// Create a document with pages
        public init(
            pages: [Page],
            info: Info? = nil,
            version: ISO_32000.Version = .v1_7
        ) {
            self.pages = pages
            self.info = info
            self.version = version
        }

        /// Create a single-page document
        public init(
            page: Page,
            info: Info? = nil,
            version: ISO_32000.Version = .v1_7
        ) {
            self.pages = [page]
            self.info = info
            self.version = version
        }

        /// Create a document with builder syntax
        ///
        /// Example:
        /// ```swift
        /// let doc = PDF.Document(title: "Report", author: "Jane") {
        ///     PDF.Page(paperSize: .a4) {
        ///         PDF.Content.text("Hello", at: .init(x: 72, y: 72))
        ///     }
        /// }
        /// ```
        public init(
            title: String? = nil,
            author: String? = nil,
            subject: String? = nil,
            keywords: String? = nil,
            creator: String? = nil,
            producer: String? = nil,
            version: ISO_32000.Version = .v1_7,
            @Page.Builder pages build: () -> [Page]
        ) {
            self.pages = build()
            self.version = version
            if title != nil || author != nil || subject != nil || keywords != nil || creator != nil || producer != nil {
                self.info = Info(
                    title: title,
                    author: author,
                    subject: subject,
                    keywords: keywords,
                    creator: creator,
                    producer: producer
                )
            } else {
                self.info = nil
            }
        }
    }
}



// MARK: - Serialization

extension Array where Element == UInt8 {
    /// Create PDF bytes from a document
    ///
    /// Example:
    /// ```swift
    /// let document = PDF.Document { ... }
    /// let bytes = [UInt8](document)
    /// ```
    ///
    /// - Parameters:
    ///   - document: The PDF document to serialize
    ///   - compress: Whether to use FlateDecode compression (default: true)
    public init(
        _ document: PDF.Document,
        compress: Bool = true
    ) {
        let isoDocument = ISO_32000.Document(document)
        var writer = compress
            ? ISO_32000.Writer.flate()
            : ISO_32000.Writer()
        self = writer.write(isoDocument)
    }
}

// MARK: - ISO 32000 Conversion

extension ISO_32000.Document {
    /// Create from a high-level PDF document
    public init(_ pdf: PDF.Document) {
        self.init(
            version: pdf.version,
            pages: pdf.pages.map { ISO_32000.Page($0) },
            info: pdf.info
        )
    }
}
