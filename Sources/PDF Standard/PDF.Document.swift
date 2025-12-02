// PDF.Document.swift

public import ISO_32000
public import ISO_32000_Flate

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
    }
}

// MARK: - Document Info

extension PDF {
    /// Document metadata
    public struct Info: Sendable {
        public var title: String?
        public var author: String?
        public var subject: String?
        public var keywords: String?
        public var creator: String?
        public var producer: String?

        public init(
            title: String? = nil,
            author: String? = nil,
            subject: String? = nil,
            keywords: String? = nil,
            creator: String? = nil,
            producer: String? = nil
        ) {
            self.title = title
            self.author = author
            self.subject = subject
            self.keywords = keywords
            self.creator = creator
            self.producer = producer
        }

        /// Convert to ISO 32000 Info
        var isoInfo: ISO_32000.Info {
            ISO_32000.Info(
                title: title,
                author: author,
                subject: subject,
                keywords: keywords,
                creator: creator,
                producer: producer
            )
        }
    }
}

// MARK: - Writing

extension PDF.Document {
    /// Write document to bytes
    ///
    /// - Parameter compress: Whether to use FlateDecode compression
    /// - Returns: PDF file bytes
    public func write(compress: Bool = true) -> [UInt8] {
        let isoDocument = toISODocument()
        var writer = compress
            ? ISO_32000.Writer.flate()
            : ISO_32000.Writer()
        return writer.write(isoDocument)
    }

    /// Write document into buffer
    public func write<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        compress: Bool = true
    ) where Buffer.Element == UInt8 {
        let isoDocument = toISODocument()
        var writer = compress
            ? ISO_32000.Writer.flate()
            : ISO_32000.Writer()
        writer.write(isoDocument, into: &buffer)
    }

    /// Convert to ISO 32000 Document
    func toISODocument() -> ISO_32000.Document {
        ISO_32000.Document(
            version: version,
            pages: pages.map { $0.toISOPage() },
            info: info?.isoInfo
        )
    }
}
