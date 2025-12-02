# Native Swift PDF Generation - Implementation Plan

## Goal

Replace Apple-specific PDF generation in `/Users/coen/Developer/coenttb/swift-html-to-pdf` with native Swift packages following the swift-standards architecture.

---

## Reusable Infrastructure (Already Available)

### From swift-incits-4-1986

| Utility | PDF Use |
|---------|---------|
| `UInt8.ASCII.Serializable` protocol | Base for all PDF types |
| `UInt8.ascii.leftParenthesis/rightParenthesis` | Literal strings: `(Hello)` |
| `UInt8.ascii.lessThan/greaterThan` | Hex strings: `<48656C6C6F>` |
| `UInt8.ascii.leftBracket/rightBracket` | Arrays: `[1 2 3]` |
| `UInt8.ascii.lessThan/greaterThan` | Dictionaries: `<< >>` (doubled) |
| `UInt8.ascii.solidus` | Names: `/Type` |
| `UInt8.ascii.percentSign` | Header/comments: `%PDF-1.7` |
| `UInt8.ascii.0`...`UInt8.ascii.9` | Digit bytes |
| `byte.ascii.isDigit/isLetter/isWhitespace` | Token classification |
| `UInt8.ascii(hexDigit:)` | Parse hex strings |
| `bytes.ascii.trimming(_:)` | Normalize whitespace |
| `INCITS_4_1986.ControlCharacters.lf/cr` | Line endings |

### From swift-standards

| Utility | PDF Use |
|---------|---------|
| `UInt8.Serializable` protocol | Binary serialization base |
| `[UInt8].Endianness.big` | Cross-reference offsets |
| `buffer.append(utf8: string)` | Append text to streams |
| `buffer.append(UInt32, endianness:)` | Binary integers |
| `Double.rounded(to: places)` | Limit coordinate precision |
| `collection.firstIndex(of: needle)` | Find delimiters |
| `FloatingPointFormat` | Format coordinates |

### What We Don't Need to Implement

- Byte constants (all ASCII available via `UInt8.ascii.*`)
- Serialization protocols (use `UInt8.ASCII.Serializable`)
- Hex parsing (use `UInt8.ascii(hexDigit:)`)
- Buffer operations (use existing `append` methods)
- Whitespace handling (use existing classification + trimming)

---

## Complete swift-standards Package Triage for PDF

### ✅ ESSENTIAL - Direct Dependencies

| Package | Standard | PDF Use | Rationale |
|---------|----------|---------|-----------|
| `swift-standards` | - | Base serialization, byte utilities | Foundation for all byte operations |
| `swift-incits-4-1986` | INCITS 4-1986 (US-ASCII) | All PDF syntax is ASCII | PDF spec requires 7-bit ASCII for structure |

### ✅ ACADEMICALLY CORRECT - Should Use

| Package | Standard | PDF Use | Rationale |
|---------|----------|---------|-----------|
| `swift-rfc-4648` | RFC 4648 | Base16 for hex strings, Base64 for embedded data | PDF hex strings `<48656C6C6F>` are Base16; Base64 for ASCII85 alternative |
| `swift-ieee-754` | IEEE 754 | Real number serialization | PDF reals follow IEEE 754 semantics |
| `swift-iso-8601` | ISO 8601 | PDF date strings | PDF dates are `D:YYYYMMDDHHmmSS` (ISO 8601 derived) |
| `swift-rfc-3339` | RFC 3339 | XMP metadata timestamps | XMP uses RFC 3339 format |
| `swift-rfc-3986` | RFC 3986 | URI annotations, /URI actions | PDF link annotations reference URIs |
| `swift-iso-639` | ISO 639 | /Lang attribute for PDF/UA | Accessibility requires language codes |
| `swift-bcp-47` | BCP 47 | Language tags in tagged PDF | Full language tag support for accessibility |
| `swift-numeric-formatting-standard` | - | Real number formatting | Foundation-free `.formatted()` API for coordinates/dimensions |

### ⚠️ POTENTIALLY USEFUL - For Specific Features

| Package | Standard | PDF Use | When Needed |
|---------|----------|---------|-------------|
| `swift-iso-3166` | ISO 3166 | Country codes in metadata | PDF/A metadata, locale info |
| `swift-iso-15924` | ISO 15924 | Script codes | Tagged PDF with script identification |
| `swift-rfc-2045` | RFC 2045 (MIME) | Content-Type for embedded files | PDF/A-3 with embedded attachments |
| `swift-rfc-2046` | RFC 2046 (MIME types) | Media type for attachments | `application/pdf`, embedded file types |
| `swift-rfc-5234` | RFC 5234 (ABNF) | Grammar specification | If building formal PDF parser |
| `swift-rfc-3987` | RFC 3987 (IRI) | Internationalized URIs | Non-ASCII characters in link URLs |
| `swift-iso-9899` | ISO 9899 (C math) | Math functions | Complex calculations if needed |

### ❌ NOT RELEVANT - Different Domains

| Package | Domain | Why Not Relevant |
|---------|--------|------------------|
| `swift-rfc-1035`, `swift-rfc-1123` | DNS | PDF doesn't do DNS resolution |
| `swift-rfc-791`, `swift-rfc-4291`, `swift-rfc-4007`, `swift-rfc-5952` | IP Addresses | PDF doesn't handle network addressing |
| `swift-ipv4-standard`, `swift-ipv6-standard` | IP | Same as above |
| `swift-rfc-2822`, `swift-rfc-5321`, `swift-rfc-5322`, `swift-rfc-6531` | Email | Different document format |
| `swift-rfc-2369`, `swift-rfc-2387`, `swift-rfc-2388`, `swift-rfc-2183` | Email/MIME | Email-specific headers |
| `swift-emailaddress-standard`, `swift-email-standard` | Email | Email validation |
| `swift-domain-standard` | Domains | Domain validation |
| `swift-rfc-9110`, `swift-rfc-9111`, `swift-rfc-9112` | HTTP | PDF is not HTTP |
| `swift-rfc-6265` | Cookies | Web sessions |
| `swift-rfc-6238` | TOTP | Time-based OTP |
| `swift-rfc-6750`, `swift-rfc-7617` | OAuth/Auth | Authentication protocols |
| `swift-rfc-7519` | JWT | Token format |
| `swift-rfc-6570` | URI Templates | URL templating |
| `swift-rfc-8058` | One-Click Unsubscribe | Email specific |
| `swift-rfc-7405` | Case-sensitive ABNF | Grammar extension |
| `swift-rfc-3492` | Punycode | Domain encoding |
| `swift-rfc-5890` | IDNA | Internationalized domains |
| `swift-rfc-5646` | Language Tags | Use swift-bcp-47 instead (superset) |
| `swift-rfc-6068` | mailto: URI | Email links (use swift-rfc-3986 for generic URIs) |
| `swift-rfc-4287` | Atom Feed | Syndication format |
| `swift-rss-standard`, `swift-json-feed-standard` | Feeds | Syndication |

### ❌ CONSUMERS OF PDF - Not Dependencies (but useful for swift-pdf)

| Package | Domain | Relationship to PDF |
|---------|--------|---------------------|
| `swift-html-standard`, `swift-whatwg-html` | HTML | HTML *uses* PDF (via swift-pdf), not vice versa |
| `swift-css-standard` | CSS | `/Users/coen/Developer/swift-standards/swift-css-standard` - CSS type definitions |
| `swift-w3c-css` | CSS | `/Users/coen/Developer/swift-standards/swift-w3c-css` - W3C CSS specifications |
| `swift-css` | CSS | `/Users/coen/Developer/coenttb/swift-css` - CSS rendering/generation |
| `swift-svg-standard`, `swift-w3c-svg` | SVG | Could be *embedded in* PDF, not a dependency |
| `swift-whatwg-url` | URL | Higher-level than RFC 3986, not needed |
| `swift-uri-standard` | URI | Composite package, use RFC 3986 directly |
| `swift-locale-standard` | Locale | Composite, use ISO 639/3166 directly |
| `swift-time-standard` | Time | Composite, use ISO 8601 directly |
| `swift-base62-standard` | Base62 | Not used in PDF |

### 🆕 MISSING - Would Need to Create for Full PDF

| Standard | Purpose | Priority |
|----------|---------|----------|
| RFC 1950 (ZLIB) | FlateDecode compression | **Phase 2** |
| RFC 1951 (DEFLATE) | Compression algorithm | **Phase 1** |
| ISO 32000 | PDF specification | **Phase 3** |
| RFC 5652 (CMS) | Digital signatures | Post-MVP |
| RFC 3161 (TSP) | Timestamp protocol | Post-MVP |
| RFC 5280 (X.509) | Certificates | Post-MVP |
| FIPS 197 (AES) | Encryption | Post-MVP |
| ISO 10918-1 (JPEG) | DCTDecode images | Post-MVP |
| ISO 15444-1 (JPEG2000) | JPXDecode images | Post-MVP |
| ISO 16684 (XMP) | Metadata | Post-MVP (for PDF/A) |
| ISO 15076 (ICC) | Color profiles | Post-MVP |
| ISO 14496-22 (OpenType) | Font embedding | Post-MVP |

---

## Recommended Dependency Graph for swift-iso-32000

```
swift-iso-32000 (core)
├── swift-standards (base)
├── swift-incits-4-1986 (ASCII)
├── swift-rfc-4648 (hex strings via Base16)
├── swift-ieee-754 (real number semantics)
├── swift-iso-8601 (date strings)
└── swift-numeric-formatting-standard (real number formatting)

swift-iso-32000-flate (optional target in same package)
├── swift-iso-32000 (core target)
└── swift-rfc-1950 (ZLIB, which depends on swift-rfc-1951)

swift-pdf-standard (unified API)
├── swift-iso-32000
├── swift-rfc-3986 (URI actions)
├── swift-bcp-47 (language tags, optional)
└── swift-iso-639 (language codes, optional)
```

**Note**: `swift-rfc-1951` (DEFLATE) is a dependency of `swift-rfc-1950` (ZLIB), not a direct dependency of ISO 32000.

---

## STANDARD_IMPLEMENTATION_PATTERNS.md Compliance

### Patterns to Apply

| Pattern | Applies To | Notes |
|---------|------------|-------|
| **NS-1** Main Namespace | `RFC_1950`, `RFC_1951`, `ISO_32000` | Empty enum as namespace |
| **NS-2** Nested Type | All types under namespace | `ISO_32000.COS.Name`, `RFC_1950.Adler32` |
| **NS-3** Deeply Nested | `ISO_32000.COS.*` types | COS is sub-namespace |
| **NS-4** Feature Area | `ISO_32000.COS`, `ISO_32000.Document` | Logical groupings |
| **SER-1** Serializable | All PDF types | Conform to `UInt8.ASCII.Serializable` |
| **SER-3** Complex Serialize | `COS.Object`, `COS.Dictionary` | Multiple fields |
| **SER-4** Dual Serialization | `COS.Stream` | Binary data + ASCII header |
| **ERR-1** Error Type | Each type with validation | Nested under type |
| **PROTO-2** Case-Sensitive | PDF Names | PDF is case-SENSITIVE (not like most RFCs) |
| **SAFE-1** Parse Don't Validate | All types | `private init(__unchecked:)` pattern |
| **SAFE-2** Limits | Stream lengths, name lengths | `package enum Limits` |
| **CONST-1** Static Constants | Well-known Names | `/Type`, `/Page`, `/Font`, etc. |
| **FILE-1** exports.swift | All packages | Re-export dependencies |
| **PKG-1** Package.swift | All packages | Standard structure |

### PDF-Specific Pattern Decisions

**1. Case Sensitivity (PROTO-2, not PROTO-1)**

PDF Names are **case-sensitive** per ISO 32000:
```swift
// CORRECT for PDF
extension ISO_32000.COS.Name: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)  // NO .lowercased()
    }
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue == rhs.rawValue  // NO .lowercased()
    }
}
```

**2. Dual Serialization (SER-4)**

PDF has both ASCII syntax and binary content:
```swift
// COS.Stream has BOTH representations
extension ISO_32000.COS.Stream: UInt8.Serializable {
    /// Binary: raw stream data (for embedding in PDF file)
    public static func serialize<Buffer>(_ value: Self, into buffer: inout Buffer)
    where Buffer.Element == UInt8 {
        // Dictionary as ASCII
        Dictionary.serialize(ascii: value.dictionary, into: &buffer)
        buffer.append(contentsOf: "\nstream\n".utf8)
        // Data as binary
        buffer.append(contentsOf: value.data)
        buffer.append(contentsOf: "\nendstream".utf8)
    }
}

extension ISO_32000.COS.Stream: UInt8.ASCII.Serializable {
    /// ASCII: for display/debugging only
    public static func serialize<Buffer>(ascii value: Self, into buffer: inout Buffer)
    where Buffer.Element == UInt8 {
        Dictionary.serialize(ascii: value.dictionary, into: &buffer)
        buffer.append(contentsOf: " stream<\(value.data.count) bytes>".utf8)
    }
}
```

**3. Static Constants (CONST-1)**

Well-known PDF names use `__unchecked`:
```swift
// ISO_32000.COS.Name.swift
extension ISO_32000.COS.Name {
    // Compile-time constants - guaranteed valid
    public static let type = Name(__unchecked: (), rawValue: "Type")
    public static let page = Name(__unchecked: (), rawValue: "Page")
    public static let pages = Name(__unchecked: (), rawValue: "Pages")
    public static let catalog = Name(__unchecked: (), rawValue: "Catalog")
    public static let font = Name(__unchecked: (), rawValue: "Font")
    public static let contents = Name(__unchecked: (), rawValue: "Contents")
    public static let resources = Name(__unchecked: (), rawValue: "Resources")
    public static let mediaBox = Name(__unchecked: (), rawValue: "MediaBox")
    public static let length = Name(__unchecked: (), rawValue: "Length")
    public static let filter = Name(__unchecked: (), rawValue: "Filter")
    public static let flateDecode = Name(__unchecked: (), rawValue: "FlateDecode")
    // ... 100+ more well-known names
}
```

**4. Limits (SAFE-2)**

PDF has specification limits:
```swift
extension ISO_32000.COS.Name {
    package enum Limits {
        // Per ISO 32000-1 Annex C - measured in BYTES (UTF-8), not String.count
        static let maxLength = 127
    }

    public init(_ raw: some StringProtocol) throws(Error) {
        // IMPORTANT: Use UTF-8 byte count, not character count
        guard raw.utf8.count <= Limits.maxLength else { throw .tooLong }
        // ... other validation
    }
}

extension ISO_32000.COS.StringValue {
    package enum Limits {
        static let maxLiteralLength = 65535  // Recommended limit
    }
}
```

### File Structure Following Patterns

```
Sources/RFC 1951/
├── RFC_1951.swift                      # NS-1: Main namespace
├── RFC_1951.Level.swift                # NS-2: Nested type
├── RFC_1951.Compress.swift             # Feature functions
├── RFC_1951.Decompress.swift
├── RFC_1951.Error.swift                # ERR-1: Error type
└── exports.swift                       # FILE-1

Sources/RFC 1950/
├── RFC_1950.swift                      # NS-1
├── RFC_1950.Adler32.swift              # NS-2 + SER-1
├── RFC_1950.Adler32.Error.swift        # ERR-1
├── RFC_1950.wrap.swift
├── RFC_1950.unwrap.swift
├── RFC_1950.Error.swift
└── exports.swift

Sources/ISO 32000/
├── ISO_32000.swift                     # NS-1: Main namespace
├── ISO_32000.Version.swift             # NS-2
├── ISO_32000.COS.swift                 # NS-4: Feature area namespace
├── ISO_32000.COS.Object.swift          # NS-3 + SER-3 (complex)
├── ISO_32000.COS.Object.Error.swift    # ERR-1
├── ISO_32000.COS.Name.swift            # NS-3 + SER-1 + CONST-1
├── ISO_32000.COS.Name.Error.swift      # ERR-1
├── ISO_32000.COS.StringValue.swift     # NS-3 + SER-1
├── ISO_32000.COS.StringValue.Error.swift
├── ISO_32000.COS.Dictionary.swift      # NS-3 + SER-3
├── ISO_32000.COS.Array.swift           # NS-3 + SER-3
├── ISO_32000.COS.Stream.swift          # NS-3 + SER-4 (dual)
├── ISO_32000.COS.Stream.Error.swift
├── ISO_32000.COS.IndirectReference.swift
├── ISO_32000.COS.serialize.swift       # Shared serialization helpers
├── ISO_32000.Document.swift            # NS-2
├── ISO_32000.Page.swift
├── ISO_32000.Rectangle.swift
├── ISO_32000.Font.swift
├── ISO_32000.Font.Standard14.swift
├── ISO_32000.Font.Metrics.swift
├── ISO_32000.ContentStream.swift
├── ISO_32000.StreamCompression.swift   # PDFStreamCompression struct + .none
├── ISO_32000.Writer.swift
├── ISO_32000.Writer.Builder.swift
├── ISO_32000.Validation.swift          # AUTH-1: Authoritative validation
├── Collection+ISO_32000.swift          # WRAP-1: Extensions
└── exports.swift                       # FILE-1
```

### Required Conformances (RULE-8)

**Leaf types** (Name, StringValue, Rectangle, IndirectReference) MUST conform to:
```swift
extension ISO_32000.COS.Name: Sendable {}                    // ✓ Required
extension ISO_32000.COS.Name: Hashable {}                    // ✓ PROTO-2 (case-sensitive)
extension ISO_32000.COS.Name: Codable {}                     // ✓ Required for leaf types
extension ISO_32000.COS.Name: UInt8.ASCII.Serializable {}    // ✓ SER-1
extension ISO_32000.COS.Name: UInt8.ASCII.RawRepresentable {} // ✓ Required
extension ISO_32000.COS.Name: CustomStringConvertible {}     // ✓ Required
```

**Complex types** (COS.Object, COS.Stream, Document) - Codable deferred:
```swift
extension ISO_32000.COS.Object: Sendable {}                  // ✓ Required
extension ISO_32000.COS.Object: Hashable {}                  // ✓ Required
extension ISO_32000.COS.Object: UInt8.ASCII.Serializable {}  // ✓ Required
extension ISO_32000.COS.Object: CustomStringConvertible {}   // ✓ Required
// Codable: DEFERRED - semantic mapping unclear, add later with versioning story
```

**Rationale**: Codable for recursive/complex types like COS.Object requires careful design for backward compatibility. Start with the core protocols; add Codable once we have a clear serialization format and versioning strategy.

### Checklist for Each PDF Type

```markdown
## Type: ISO_32000.COS.Name

### Files
- [x] ISO_32000.COS.Name.swift (NS-3)
- [x] ISO_32000.COS.Name.Error.swift (ERR-1)
- [x] Updated exports.swift (FILE-1)

### Required Conformances
- [x] UInt8.ASCII.Serializable (SER-1)
- [x] UInt8.ASCII.RawRepresentable
- [x] CustomStringConvertible
- [x] Hashable (PROTO-2: case-sensitive)
- [x] Sendable
- [x] Codable

### Required Members
- [x] public let rawValue: String
- [x] private init(__unchecked: Void, rawValue: String) (SAFE-1a)
- [x] public init(rawValue: String) throws(Error) (SAFE-1b)
- [x] init<Bytes: Collection>(ascii:in:) calls public init (SAFE-1c)
- [x] static func serialize<Buffer>(ascii:into:) (SER-2)
- [x] Static constants use __unchecked (CONST-1)

### Error Type (ERR-1)
- [x] Nested enum Error
- [x] Conforms to Swift.Error, Sendable, Equatable
- [x] Conforms to CustomStringConvertible
- [x] case empty
- [x] case tooLong
- [x] case invalidCharacter(byte:)
- [x] case containsNullByte
- [x] case containsWhitespace

### Validation (per ISO 32000 7.3.5)
- [x] Validates non-empty
- [x] Validates no null bytes (0x00)
- [x] Validates no whitespace
- [x] Validates length <= 127 bytes (SAFE-2)
```

---

## Package Architecture

```
swift-standards (base)
        │
        ├── swift-rfc-1951 (DEFLATE compression)
        │         │
        ├── swift-rfc-1950 (ZLIB wrapper)
        │
        └── swift-iso-32000 (PDF object model)
                    │
                    ├── ISO 32000 Flate (optional target, depends on RFC 1950)
                    │
                    └── swift-pdf-standard (unified API)
                                │
                                swift-pdf-rendering (layout engine)
                                        │
                                        swift-pdf (HTML integration)
```

**Key architectural change**: `swift-iso-32000` does NOT depend on RFC 1950 directly. Instead:
- Core `ISO 32000` target has no compression dependency
- Optional `ISO 32000 Flate` target provides FlateDecode via protocol injection
- This keeps `swift-iso-32000` compilable/testable without DEFLATE

---

## Phase 1: DEFLATE Compression

**Package:** `swift-rfc-1951`
**Location:** `/Users/coen/Developer/swift-standards/swift-rfc-1951`

### Files to Create

```
Sources/RFC 1951/
├── RFC_1951.swift                    # Namespace
├── RFC_1951.Level.swift              # Compression levels (0-9)
├── RFC_1951.Compress.swift           # compress(_:into:level:) + convenience returning [UInt8]
├── RFC_1951.Decompress.swift         # decompress(_:into:)
├── RFC_1951.Huffman.swift            # Huffman coding tables
├── RFC_1951.LZ77.swift               # Sliding window compression (state machine for future streaming)
├── RFC_1951.Block.swift              # Block structure (stored, fixed, dynamic)
├── RFC_1951.Error.swift              # Error types
└── exports.swift
```

### Key Types

```swift
public enum RFC_1951 {
    public enum Level: Int, Sendable {
        case none = 0, fast = 1, balanced = 5, best = 9
    }

    /// Streaming API (into buffer)
    public static func compress<Input, Output>(
        _ input: Input, into output: inout Output, level: Level = .balanced
    ) where Input: Collection, Input.Element == UInt8,
            Output: RangeReplaceableCollection, Output.Element == UInt8

    /// Convenience API (returns new array)
    public static func compress<Bytes>(
        _ input: Bytes, level: Level = .balanced
    ) -> [UInt8] where Bytes: Collection, Bytes.Element == UInt8

    public static func decompress<Input, Output>(
        _ input: Input, into output: inout Output
    ) throws(Error) where Input: Collection, Input.Element == UInt8,
                          Output: RangeReplaceableCollection, Output.Element == UInt8
}
```

### Implementation Notes

- **Pure Swift** (no C zlib dependency) for cross-platform support and WASM compatibility
- Internal engine designed as **state machine** for future streaming support
- Collection-based APIs for MVP, streaming APIs can be added later
- **Fallback only if needed**: If pure Swift DEFLATE proves too complex for initial implementation, delegate to system zlib temporarily. However, pure Swift is strongly preferred.

### Raw DEFLATE API (Reserved)

PDF allows `/Filter /FlateDecode` without ZLIB wrapping in certain contexts:
- **Images in PDF** must use raw DEFLATE (no ZLIB header)
- Some PDF generators produce raw deflate, not zlib-wrapped deflate

Reserve API surface for raw DEFLATE-only streams (no ZLIB wrapping):

```swift
extension RFC_1951 {
    /// Raw DEFLATE compression without ZLIB wrapper
    /// Use for PDF image streams and other raw deflate contexts
    public static func compressRaw<Input, Output>(
        _ input: Input, into output: inout Output, level: Level = .balanced
    ) where Input: Collection, Input.Element == UInt8,
            Output: RangeReplaceableCollection, Output.Element == UInt8

    /// Raw DEFLATE decompression without ZLIB header validation
    public static func decompressRaw<Input, Output>(
        _ input: Input, into output: inout Output
    ) throws(Error) where Input: Collection, Input.Element == UInt8,
                          Output: RangeReplaceableCollection, Output.Element == UInt8
}
```

**For MVP**: `compressRaw` and `decompressRaw` can delegate to the same internal implementation as `compress`/`decompress`. The only difference is the ZLIB wrapper in RFC 1950. This API is reserved now so future image embedding doesn't require breaking changes.

---

## Phase 2: ZLIB Format

**Package:** `swift-rfc-1950`
**Location:** `/Users/coen/Developer/swift-standards/swift-rfc-1950`

### Files to Create

```
Sources/RFC 1950/
├── RFC_1950.swift                    # Namespace
├── RFC_1950.wrap.swift               # wrap(deflated:level:into:)
├── RFC_1950.unwrap.swift             # unwrap(_:into:)
├── RFC_1950.compress.swift           # Convenience: DEFLATE + wrap in one call
├── RFC_1950.Header.swift             # CMF, FLG bytes
├── RFC_1950.Adler32.swift            # Incremental checksum type
├── RFC_1950.Error.swift              # Error types
└── exports.swift
```

### Key Types

```swift
public enum RFC_1950 {
    /// Incremental Adler-32 checksum (reusable in other standards)
    public struct Adler32: Sendable {
        public init(seed: UInt32 = 1)
        public mutating func update<Bytes>(_ bytes: Bytes)
            where Bytes: Collection, Bytes.Element == UInt8
        public var value: UInt32 { get }

        /// Convenience for one-shot checksum
        public static func checksum<Bytes>(_ bytes: Bytes) -> UInt32
            where Bytes: Collection, Bytes.Element == UInt8
    }

    public static func wrap<Input, Output>(
        deflated input: Input, level: RFC_1951.Level, into output: inout Output
    ) where Input: Collection, Input.Element == UInt8,
            Output: RangeReplaceableCollection, Output.Element == UInt8

    /// Convenience: DEFLATE + ZLIB wrap in one call
    public static func compress<Input, Output>(
        _ input: Input, into output: inout Output, level: RFC_1951.Level = .balanced
    ) where Input: Collection, Input.Element == UInt8,
            Output: RangeReplaceableCollection, Output.Element == UInt8
}
```

---

## Phase 3: PDF Object Model

**Package:** `swift-iso-32000`
**Location:** `/Users/coen/Developer/swift-standards/swift-iso-32000`

### Package Structure (Multi-Target)

```swift
// Package.swift for swift-iso-32000
let package = Package(
    name: "swift-iso-32000",
    products: [
        .library(name: "ISO 32000", targets: ["ISO 32000"]),
        .library(name: "ISO 32000 Flate", targets: ["ISO 32000 Flate"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-rfc-4648.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-ieee-754.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-iso-8601.git", from: "0.1.0"),
        .package(url: "https://github.com/swift-standards/swift-numeric-formatting-standard.git", from: "0.1.0"),
        // RFC 1950 only needed for Flate target
        .package(url: "https://github.com/swift-standards/swift-rfc-1950.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "ISO 32000",
            dependencies: [
                .product(name: "Standards", package: "swift-standards"),
                .product(name: "INCITS 4 1986", package: "swift-incits-4-1986"),
                .product(name: "RFC 4648", package: "swift-rfc-4648"),
                .product(name: "IEEE 754", package: "swift-ieee-754"),
                .product(name: "ISO 8601", package: "swift-iso-8601"),
                .product(name: "Numeric Formatting", package: "swift-numeric-formatting-standard"),
            ]
        ),
        .target(
            name: "ISO 32000 Flate",
            dependencies: [
                "ISO 32000",
                .product(name: "RFC 1950", package: "swift-rfc-1950"),
            ]
        ),
    ]
)
```

**Note**: Repository is `swift-iso-32000` (lowercase with hyphens), targets are `ISO 32000` and `ISO 32000 Flate` (spaces, per swift-standards convention).

### Files to Create

```
Sources/ISO 32000/
├── ISO_32000.swift                   # Namespace
├── ISO_32000.COS.swift               # Carousel Object System namespace
├── ISO_32000.COS.Object.swift        # enum Object (9 types)
├── ISO_32000.COS.Name.swift          # PDF Name (validated: no null/whitespace)
├── ISO_32000.COS.StringValue.swift   # With explicit encoding (PDFDoc vs UTF-16BE)
├── ISO_32000.COS.Dictionary.swift    # PDF Dictionary
├── ISO_32000.COS.Stream.swift        # PDF Stream (dictionary + data)
├── ISO_32000.COS.IndirectReference.swift
├── ISO_32000.COS.serialize.swift     # Serialize Object to PDF syntax
├── ISO_32000.Document.swift          # High-level document structure
├── ISO_32000.Version.swift           # PDF version enum (1.4, 1.7, 2.0)
├── ISO_32000.Page.swift              # Page structure
├── ISO_32000.Rectangle.swift         # MediaBox, CropBox (with A4, Letter presets)
├── ISO_32000.Resources.swift         # Page resources (fonts, xobjects)
├── ISO_32000.Font.swift              # Font types
├── ISO_32000.Font.Standard14.swift   # Standard 14 fonts enum
├── ISO_32000.Font.Metrics.swift      # Canonical glyph widths (single source of truth)
├── ISO_32000.ContentStream.swift     # Content stream builder
├── ISO_32000.ContentStream.Operator.swift  # Internal operator enum (canonical serialization)
├── ISO_32000.StreamCompression.swift # PDFStreamCompression struct + .none
├── ISO_32000.Writer.swift            # Serialize Document to PDF bytes
├── ISO_32000.Writer.Builder.swift    # Builds COS tree, assigns object numbers
├── ISO_32000.Error.swift
└── exports.swift

Sources/ISO 32000 Flate/
├── PDFStreamCompression+Flate.swift  # extension PDFStreamCompression { static func flate(...) }
└── exports.swift
```

### Standard 14 Font Metrics Data Source

The Standard 14 fonts (also called "Base 14") are guaranteed to be available in every PDF reader. Their metrics are published by Adobe in AFM (Adobe Font Metrics) files.

**Data Source**: Adobe's AFM files from the Adobe Type 1 Font Format specification.

| Font Name | AFM File |
|-----------|----------|
| Helvetica | `Helvetica.afm` |
| Helvetica-Bold | `Helvetica-Bold.afm` |
| Helvetica-Oblique | `Helvetica-Oblique.afm` |
| Helvetica-BoldOblique | `Helvetica-BoldOblique.afm` |
| Times-Roman | `Times-Roman.afm` |
| Times-Bold | `Times-Bold.afm` |
| Times-Italic | `Times-Italic.afm` |
| Times-BoldItalic | `Times-BoldItalic.afm` |
| Courier | `Courier.afm` |
| Courier-Bold | `Courier-Bold.afm` |
| Courier-Oblique | `Courier-Oblique.afm` |
| Courier-BoldOblique | `Courier-BoldOblique.afm` |
| Symbol | `Symbol.afm` |
| ZapfDingbats | `ZapfDingbats.afm` |

**Implementation approach**:

1. **Parse AFM at build time** - Create a build-time script that parses AFM files and generates Swift code with static glyph width tables
2. **Store as static dictionaries** - Each font gets a `[UnicodeScalar: Int]` dictionary mapping characters to widths in font design units (1000 units per em)
3. **Include only glyph widths** - For MVP, only `CharMetrics` (per-glyph widths) are needed. Kerning pairs, ligatures, and other advanced metrics are deferred.

**File structure**:

```
Sources/ISO 32000/
├── ISO_32000.Font.Metrics.swift           # Public API: stringWidth(_:atSize:), glyphWidth(for:)
├── ISO_32000.Font.Metrics.Helvetica.swift # Generated: static width table
├── ISO_32000.Font.Metrics.Times.swift     # Generated: static width table
├── ISO_32000.Font.Metrics.Courier.swift   # Generated: static width table (fixed-width: 600)
├── ISO_32000.Font.Metrics.Symbol.swift    # Generated: static width table
├── ISO_32000.Font.Metrics.ZapfDingbats.swift # Generated: static width table
```

**Note**: Courier is fixed-width (600 units for all glyphs), so its table is trivial.

**AFM file availability**: Adobe's AFM files for the Standard 14 fonts are freely available and have been redistributed in many open-source projects (Ghostscript, PDFBox, libharu, etc.). They are not copyrighted content—only the font programs themselves are protected.

### Key Types

```swift
extension ISO_32000.COS {
    public enum Object: Sendable {
        case null
        case boolean(Bool)
        case integer(Int64)  // Platform-independent, not Int
        case real(Double)
        case name(Name)
        case string(StringValue)
        case array([Object])
        case dictionary(Dictionary)
        case stream(Stream)
        case reference(IndirectReference)
    }
}

// Example: All PDF types conform to existing UInt8.ASCII.Serializable
extension ISO_32000.COS.Object: UInt8.ASCII.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Self, into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        switch value {
        case .null:
            buffer.append(contentsOf: "null".utf8)
        case .boolean(true):
            buffer.append(contentsOf: "true".utf8)
        case .boolean(false):
            buffer.append(contentsOf: "false".utf8)
        case .integer(let n):
            buffer.append(contentsOf: String(n).utf8)
        case .real(let n):
            // Use swift-numeric-formatting-standard for proper precision
            buffer.append(contentsOf: n.formatted(.number.precision(.fractionLength(...6))).utf8)
        case .name(let name):
            Name.serialize(ascii: name, into: &buffer)
        case .string(let str):
            StringValue.serialize(ascii: str, into: &buffer)
        case .array(let arr):
            buffer.append(.ascii.leftBracket)    // [
            for (i, obj) in arr.enumerated() {
                if i > 0 { buffer.append(.ascii.space) }
                Self.serialize(ascii: obj, into: &buffer)
            }
            buffer.append(.ascii.rightBracket)   // ]
        case .dictionary(let dict):
            Dictionary.serialize(ascii: dict, into: &buffer)
        case .stream(let stream):
            Stream.serialize(ascii: stream, into: &buffer)
        case .reference(let ref):
            IndirectReference.serialize(ascii: ref, into: &buffer)
        }
    }
}

extension ISO_32000.COS {
    /// PDF Name object - validated at construction
    public struct Name: Sendable, Hashable, UInt8.ASCII.Serializable {
        public let rawValue: String

        private init(__unchecked: Void, rawValue: String) { self.rawValue = rawValue }

        /// Validates: no null bytes, no whitespace
        public init(_ raw: some StringProtocol) throws(Error)

        // Well-known constants
        public static let type, page, pages, catalog, font, contents: Name
        public static let resources, mediaBox, length, filter, flateDecode: Name
    }
}

extension ISO_32000.COS {
    /// PDF String with explicit encoding
    public struct StringValue: Sendable, Hashable {
        public enum Encoding: Sendable {
            case pdfDocEncoding      // Latin-1 subset
            case utf16BEWithBOM      // Unicode text
        }

        public var encoding: Encoding
        public var scalarValues: [UnicodeScalar]

        /// Convenience from String - ALWAYS uses UTF-16BE with BOM
        /// (PDFDocEncoding requires explicit opt-in for legacy use cases)
        public init(_ string: String)

        /// Literal string: (Hello)
        public var asLiteral: [UInt8] { get }

        /// Hex string: <48656C6C6F>
        public var asHexadecimal: [UInt8] { get }
    }
}

extension ISO_32000.COS.StringValue {
    /// Escape table for literal strings (ISO 32000-1 Table 3)
    /// These bytes MUST be escaped when appearing in literal strings
    package static let literalEscapeTable: [UInt8: [UInt8]] = [
        0x0A: [0x5C, 0x6E],  // \n (linefeed)
        0x0D: [0x5C, 0x72],  // \r (carriage return)
        0x09: [0x5C, 0x74],  // \t (horizontal tab)
        0x08: [0x5C, 0x62],  // \b (backspace)
        0x0C: [0x5C, 0x66],  // \f (form feed)
        0x28: [0x5C, 0x28],  // \( (left parenthesis)
        0x29: [0x5C, 0x29],  // \) (right parenthesis)
        0x5C: [0x5C, 0x5C],  // \\ (backslash)
    ]

    /// Determines preferred encoding based on content analysis
    /// - Returns `.literal` for ASCII-only content with few escapes needed
    /// - Returns `.hexadecimal` for binary data or content needing many escapes
    public var preferredSerializationFormat: SerializationFormat {
        var escapeCount = 0
        var nonPrintableCount = 0

        for scalar in scalarValues {
            let byte = UInt8(truncatingIfNeeded: scalar.value)
            if Self.literalEscapeTable[byte] != nil {
                escapeCount += 1
            }
            if byte < 0x20 && Self.literalEscapeTable[byte] == nil {
                nonPrintableCount += 1
            }
        }

        // Heuristic: use hex if >25% would need escaping or contains unprintable bytes
        let total = scalarValues.count
        if nonPrintableCount > 0 || (total > 0 && Double(escapeCount) / Double(total) > 0.25) {
            return .hexadecimal
        }
        return .literal
    }

    public enum SerializationFormat: Sendable {
        case literal      // (Hello World)
        case hexadecimal  // <48656C6C6F20576F726C64>
    }
}

extension ISO_32000.COS.StringValue: UInt8.ASCII.Serializable {
    public static func serialize<Buffer>(ascii value: Self, into buffer: inout Buffer)
    where Buffer.Element == UInt8 {
        // Serializer decides hex vs literal based on content analysis
        switch value.preferredSerializationFormat {
        case .literal:
            buffer.append(contentsOf: value.asLiteral)
        case .hexadecimal:
            buffer.append(contentsOf: value.asHexadecimal)
        }
    }
}
```

### Content Stream Operator Model

**Problem**: Without a canonical operator representation, two risks emerge:
1. Duplicate or inconsistent implementations of operators (Tj, Tm, m, l, etc.)
2. Hard-to-test correctness (because raw strings get assembled in different places)

**Solution**: Internal sealed enum for all content stream operators.

```swift
extension ISO_32000.ContentStream {
    /// Internal operator representation - canonical source for PDF content stream commands
    /// This enum NEVER escapes ISO_32000; it's internal to the content stream subsystem.
    ///
    /// Benefits:
    /// - Canonical serialization table (one place)
    /// - One unit test per operator
    /// - Layout engine becomes higher-level and safer
    package enum Operator: Sendable {
        // Graphics state operators
        case saveState                                    // q
        case restoreState                                 // Q
        case setLineWidth(Double)                         // w
        case setLineCap(Int)                              // J
        case setLineJoin(Int)                             // j
        case setMiterLimit(Double)                        // M
        case setDashPattern([Double], Double)             // d

        // Path construction operators
        case moveTo(x: Double, y: Double)                 // m
        case lineTo(x: Double, y: Double)                 // l
        case curveTo(x1: Double, y1: Double, x2: Double, y2: Double, x3: Double, y3: Double)  // c
        case closePath                                    // h
        case rectangle(x: Double, y: Double, width: Double, height: Double)  // re

        // Path painting operators
        case stroke                                       // S
        case closeAndStroke                               // s
        case fill                                         // f
        case fillEvenOdd                                  // f*
        case fillAndStroke                                // B
        case fillAndStrokeEvenOdd                         // B*
        case endPath                                      // n

        // Color operators
        case setStrokeGray(Double)                        // G
        case setFillGray(Double)                          // g
        case setStrokeRGB(r: Double, g: Double, b: Double)  // RG
        case setFillRGB(r: Double, g: Double, b: Double)    // rg

        // Text state operators
        case beginText                                    // BT
        case endText                                      // ET
        case setFont(name: COS.Name, size: Double)        // Tf
        case setTextLeading(Double)                       // TL
        case setCharacterSpacing(Double)                  // Tc
        case setWordSpacing(Double)                       // Tw
        case setTextRise(Double)                          // Ts

        // Text positioning operators
        case moveTextPosition(tx: Double, ty: Double)     // Td
        case moveTextPositionWithLeading(tx: Double, ty: Double)  // TD
        case setTextMatrix(a: Double, b: Double, c: Double, d: Double, e: Double, f: Double)  // Tm
        case moveToNextLine                               // T*

        // Text showing operators
        case showText(COS.StringValue)                    // Tj
        case showTextNextLine(COS.StringValue)            // '
        case showTextWithSpacing(wordSpace: Double, charSpace: Double, text: COS.StringValue)  // "
        case showTextArray([TextArrayElement])            // TJ

        enum TextArrayElement: Sendable {
            case text(COS.StringValue)
            case spacing(Double)  // negative = move right, positive = move left
        }
    }
}

extension ISO_32000.ContentStream.Operator: UInt8.ASCII.Serializable {
    /// Canonical serialization - single source of truth for operator output
    package static func serialize<Buffer>(ascii op: Self, into buffer: inout Buffer)
    where Buffer.Element == UInt8 {
        switch op {
        case .saveState:
            buffer.append(contentsOf: "q".utf8)
        case .restoreState:
            buffer.append(contentsOf: "Q".utf8)
        case .moveTo(let x, let y):
            // Uses swift-numeric-formatting-standard for precision
            buffer.append(contentsOf: "\(x.formatted(.number.precision(.fractionLength(...4)))) ".utf8)
            buffer.append(contentsOf: "\(y.formatted(.number.precision(.fractionLength(...4)))) m".utf8)
        case .lineTo(let x, let y):
            buffer.append(contentsOf: "\(x.formatted(.number.precision(.fractionLength(...4)))) ".utf8)
            buffer.append(contentsOf: "\(y.formatted(.number.precision(.fractionLength(...4)))) l".utf8)
        case .beginText:
            buffer.append(contentsOf: "BT".utf8)
        case .endText:
            buffer.append(contentsOf: "ET".utf8)
        case .setFont(let name, let size):
            COS.Name.serialize(ascii: name, into: &buffer)
            buffer.append(contentsOf: " \(size.formatted(.number.precision(.fractionLength(...2)))) Tf".utf8)
        case .showText(let text):
            COS.StringValue.serialize(ascii: text, into: &buffer)
            buffer.append(contentsOf: " Tj".utf8)
        // ... other operators follow same pattern
        default:
            fatalError("Operator not yet implemented: \(op)")
        }
    }
}
```

**Testing**: Each operator case gets exactly one unit test validating its serialized output:

```swift
func testMoveToOperator() {
    var buffer: [UInt8] = []
    ContentStream.Operator.serialize(ascii: .moveTo(x: 100, y: 200), into: &buffer)
    XCTAssertEqual(String(decoding: buffer, as: UTF8.self), "100 200 m")
}
```

### Compression Strategy (Struct with Closure)

```swift
/// Compression strategy as a struct with closure - no protocols, no enums
/// Uses inout output for consistency with RFC compress(_:into:) APIs
public struct PDFStreamCompression: Sendable {
    public var compress: @Sendable (_ input: [UInt8], _ output: inout [UInt8]) throws -> Void

    public init(
        compress: @escaping @Sendable (_ input: [UInt8], _ output: inout [UInt8]) throws -> Void
    ) {
        self.compress = compress
    }
}

// In ISO 32000 core target:
extension PDFStreamCompression {
    /// No compression - passthrough
    public static let none = Self { input, output in
        output.append(contentsOf: input)
    }
}

// In ISO 32000 Flate target:
extension PDFStreamCompression {
    /// ZLIB compression via RFC 1950
    public static func flate(level: RFC_1951.Level = .balanced) -> Self {
        Self { input, output in
            RFC_1950.compress(input, into: &output, level: level)
        }
    }
}
```

**Design rationale**:
- **Struct with closure, not protocol**: No existential `any` boxing, no protocol witness overhead
- **No enums**: An enum with `.custom(any ...)` contradicts itself - claims closed set but contains open set
- **`inout [UInt8]` output**: Consistent with RFC `compress(_:into:)` APIs, avoids extra allocation/copy
- **Static members**: Clean `.none`, `.flate()` syntax directly on the type
- **Composable**: Easy to define inline strategies without ceremony

### Writer with Compression Strategy

```swift
extension ISO_32000 {
    public struct Writer: Sendable {
        public var compression: PDFStreamCompression = .none

        public init(compression: PDFStreamCompression = .none) {
            self.compression = compression
        }

        public mutating func write<Buffer: RangeReplaceableCollection>(
            _ document: Document, into buffer: inout Buffer
        ) where Buffer.Element == UInt8 {
            // Writer is oblivious to compression choice:
            var compressed: [UInt8] = []
            try compression.compress(streamData, &compressed)
            // ... emit compressed data
        }
    }
}

// Usage:
var writer = ISO_32000.Writer()                              // no compression (default)
var writer = ISO_32000.Writer(compression: .none)            // explicit no compression
var writer = ISO_32000.Writer(compression: .flate())         // ZLIB with default level
var writer = ISO_32000.Writer(compression: .flate(level: .best))

// Inline custom strategy:
var writer = ISO_32000.Writer(compression: .init { input, output in
    // custom compression logic
    output.append(contentsOf: myCompress(input))
})
```

### Document Structure (Two Layers)

```swift
extension ISO_32000 {
    /// Ergonomic document representation
    public struct Document: Sendable {
        public var version: Version
        public var pages: [Page]
        public var info: Info?
    }
}

extension ISO_32000.Writer {
    /// Internal builder that creates valid COS tree
    struct Builder {
        // Assigns object numbers
        // Builds Pages tree with proper parent/kids references
        // Ensures exactly one Catalog
        // Generates xref table (or xref stream)
    }
}
```

---

## Phase 4: Unified PDF API

**Package:** `swift-pdf-standard`
**Location:** `/Users/coen/Developer/swift-standards/swift-pdf-standard`

### Files to Create

```
Sources/PDF Standard/
├── PDF.swift                         # Namespace
├── PDF.Document.swift                # High-level document builder
├── PDF.Page.swift                    # Page builder
├── PDF.ContentStream.swift           # Content stream builder
├── PDF.PaperSize.swift               # A4, Letter, custom
├── PDF.EdgeInsets.swift              # Margins
├── PDF.Font.swift                    # Font enum (maps to ISO_32000.Font.Standard14)
├── PDF.Color.swift                   # RGB, Grayscale
├── PDF.Text.swift                    # Text operations
├── PDF.Graphics.swift                # Graphics operations
├── PDF.RenderContext.swift           # Coordinate system (top-left origin, y-down)
└── exports.swift
```

### Coordinate System

**Decision**: PDF.RenderContext uses **top-left origin with y increasing down** (matches HTML/CSS mental model).

```swift
extension PDF {
    /// Rendering coordinate system
    /// - Origin: top-left of content area (inside margins)
    /// - Y-axis: increases downward
    /// - Units: points (1/72 inch)
    public struct RenderContext: Sendable {
        public var position: Point
        public var pageSize: PaperSize
        public var margins: EdgeInsets

        /// Available width for content
        public var availableWidth: Double {
            pageSize.width - margins.left - margins.right
        }
    }
}

extension ISO_32000.Writer {
    /// Converts top-left coordinates to PDF bottom-left coordinates
    /// THIS IS THE ONLY PLACE coordinate transformation happens.
    /// - Layout primitives NEVER do ad-hoc y inversion
    /// - All text/graphics emission calls this helper
    func transformToBottomLeft(_ point: PDF.Point, pageHeight: Double) -> (x: Double, y: Double) {
        (point.x, pageHeight - point.y)
    }
}
```

**Critical invariant**: Never do coordinate flipping in layout primitives (PDFText, PDFVStack, etc.). All coordinates flow through `transformToBottomLeft` at the final emission stage to avoid double-inversion bugs.

### Font Mapping

```swift
extension PDF {
    /// Ergonomic font selection
    public enum Font: Sendable {
        case helvetica
        case helveticaBold
        case helveticaOblique
        case helveticaBoldOblique
        case times
        case timesBold
        case timesItalic
        case timesBoldItalic
        case courier
        case courierBold
        case courierOblique
        case courierBoldOblique
        case symbol
        case zapfDingbats

        /// Maps to canonical ISO_32000.Font.Standard14
        public var standard14: ISO_32000.Font.Standard14 { get }
    }
}
```

---

## Phase 5: Layout Engine

**Package:** `swift-pdf-rendering`
**Location:** `/Users/coen/Developer/coenttb/swift-pdf-rendering`

### Files to Create

```
Sources/PDF Rendering/
├── PDFRenderable.swift               # Protocol extending Renderable
├── PDFRenderContext.swift            # Context type (font, position, available width)
├── PDFText.swift                     # Text primitive with line wrapping
├── PDFVStack.swift                   # Vertical layout
├── PDFHStack.swift                   # Horizontal layout
├── PDFTable.swift                    # Table layout
├── PDFSpacer.swift                   # Spacing primitive
├── PDFDivider.swift                  # Horizontal rule
└── exports.swift
```

### Text Measurement (Single Source of Truth)

```swift
// In ISO_32000.Font.Metrics - THE canonical source of glyph widths
extension ISO_32000.Font.Metrics {
    /// Single function for measuring string width
    /// Called by BOTH:
    /// - PDFText wrapping logic (to decide where to break lines)
    /// - Content stream writer (to compute text placement)
    public func stringWidth(_ text: String, atSize size: Double) -> Double {
        var width: Double = 0
        for scalar in text.unicodeScalars {
            width += glyphWidth(for: scalar) * size / 1000.0
        }
        return width
    }

    /// Per-glyph width in font design units (typically 1000 units per em)
    public func glyphWidth(for scalar: UnicodeScalar) -> Double
}

// In swift-pdf-rendering - delegates to canonical source
extension PDFText {
    func measureWidth(text: String, font: PDF.Font, size: Double) -> Double {
        // NEVER duplicates glyph width data - always delegates
        font.standard14.metrics.stringWidth(text, atSize: size)
    }
}
```

**Critical invariant**: `stringWidth` is the ONLY function that calculates text width. If glyph metrics are ever tweaked, everything stays aligned because there's exactly one source of truth.

---

## Phase 6: HTML Integration

**Package:** `swift-pdf`
**Location:** `/Users/coen/Developer/coenttb/swift-pdf`

### Dependencies

This package can leverage existing CSS infrastructure:
- `swift-css-standard` (`/Users/coen/Developer/swift-standards/swift-css-standard`) - CSS type definitions
- `swift-w3c-css` (`/Users/coen/Developer/swift-standards/swift-w3c-css`) - W3C CSS specifications
- `swift-css` (`/Users/coen/Developer/coenttb/swift-css`) - CSS rendering/generation

### Files to Create

```
Sources/PDF/
├── HTMLToPDF.swift                   # Main converter
├── HTMLToPDF.Configuration.swift     # Paper size, margins, CSS support level
├── HTMLElementMapping.swift          # Map HTML elements to PDF primitives
├── CSSPropertyMapping.swift          # Interpret CSS properties (using swift-css types)
└── exports.swift
```

### CSS Support (Explicit Finite Mapping)

```swift
extension HTMLToPDF.Configuration {
    public enum CSSSupport: Sendable {
        case none
        /// Explicit list of supported properties:
        /// - font-size
        /// - color
        /// - background-color
        /// - margin (block-level only)
        /// - padding (block-level only)
        /// - text-align
        /// - border (basic)
        /// Everything else is silently ignored.
        case basic
    }
}
```

### CSS Precedence Rule

**Explicit rule**: Inline styles override class styles **only for properties supported by the converter**.

```swift
extension HTMLToPDF {
    /// CSS property resolution order (most specific wins):
    /// 1. Inline style attribute: style="color: red"
    /// 2. Class styles: .foo { color: blue }
    /// 3. Element defaults: p { ... }
    /// 4. Converter defaults (from Configuration)
    ///
    /// IMPORTANT: Unsupported properties are ignored at ALL levels.
    /// A class with "display: flex" will not affect layout because
    /// flexbox is not in the supported property list.
    struct ComputedStyle {
        var fontSize: Double?
        var color: PDF.Color?
        var backgroundColor: PDF.Color?
        var margin: PDF.EdgeInsets?
        var padding: PDF.EdgeInsets?
        var textAlign: TextAlignment?
        var border: BorderStyle?

        /// Merges styles with proper precedence
        /// Later styles override earlier ones for supported properties
        mutating func merge(from: ComputedStyle) {
            if let v = from.fontSize { fontSize = v }
            if let v = from.color { color = v }
            if let v = from.backgroundColor { backgroundColor = v }
            if let v = from.margin { margin = v }
            if let v = from.padding { padding = v }
            if let v = from.textAlign { textAlign = v }
            if let v = from.border { border = v }
        }
    }
}
```

**Rationale**: The CSS spec allows inline styles to override class styles. Failure to implement this correctly causes wrong PDFs. By defining this rule explicitly with an explicit `ComputedStyle` type, we can test precedence behavior and ensure consistency.

---

## Phase 7: swift-html-to-pdf Integration

**Package:** `/Users/coen/Developer/coenttb/swift-html-to-pdf`

### Files to Modify

1. `PDF.Render.Client.swift` - Add native renderer option
2. `PDF.Render.Configuration.swift` - Add renderer selection

### API Compatibility

```swift
extension PDF.Render.Configuration {
    public enum Renderer: Sendable {
        case webKit     // Existing implementation
        case native     // New implementation
        case auto       // WebKit on macOS/iOS, native on Linux
    }
    public var renderer: Renderer
}
```

---

## MVP Scope

### Supported Features

- **Text**: Single line, multi-line with wrapping, font size, bold/italic (Standard 14 fonts)
- **Layout**: Vertical stacking, margins, page breaks
- **Graphics**: Lines, rectangles, fill, stroke, colors (RGB)
- **HTML Elements**: `<div>`, `<p>`, `<span>`, `<h1>`-`<h6>`, `<br>`, `<hr>`, `<b>`, `<strong>`, `<i>`, `<em>`, `<table>`, `<tr>`, `<td>`, `<th>`
- **CSS**: `font-size`, `color`, `background-color`, `margin`, `padding`, `text-align`, `border` (basic)

### Deferred

- Images (JPEG/PNG embedding)
- Custom fonts (TrueType/OpenType embedding)
- Links (PDF annotations)
- Advanced CSS (flexbox, grid)
- PDF forms
- PDF/A compliance
- Encryption/signatures
- xref streams (use classic xref table for now)

---

## Critical Files Reference

| File | Purpose |
|------|---------|
| `/Users/coen/Developer/swift-standards/STANDARD_IMPLEMENTATION_PATTERNS.md` | Required patterns for all swift-standards packages |
| `/Users/coen/Developer/swift-standards/swift-rfc-4648/Sources/RFC 4648/RFC_4648.Base64.swift` | Pattern for encoding packages |
| `/Users/coen/Developer/coenttb/swift-renderable/Sources/Renderable/Renderable.swift` | Base protocol for rendering |
| `/Users/coen/Developer/coenttb/swift-html-rendering/Sources/HTML Renderable/` | HTML rendering patterns to mirror |
| `/Users/coen/Developer/coenttb/swift-html-to-pdf/Sources/HtmlToPdfTypes/PDF.Document.swift` | Existing API to maintain compatibility |

---

## Implementation Order

1. **swift-rfc-1951** - DEFLATE compression (standalone package, testable)
2. **swift-rfc-1950** - ZLIB wrapper (standalone package, depends on RFC 1951)
3. **swift-iso-32000** - PDF object model with two targets:
   - `ISO 32000` target - Core PDF types (NO compression dependency)
   - `ISO 32000 Flate` target - Optional FlateDecode compression (depends on RFC 1950)
4. **swift-pdf-standard** - Unified API (depends on ISO 32000)
5. **swift-pdf-rendering** - Layout engine (depends on swift-pdf-standard, swift-renderable)
6. **swift-pdf** - HTML integration (depends on swift-pdf-rendering, swift-html-rendering)
7. **swift-html-to-pdf** - Add native renderer option

Each phase produces a standalone, testable package/target before moving to the next.

---

## Key Architectural Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| DEFLATE implementation | Pure Swift (or temp zlib shim) | Cross-platform, WASM future |
| Compression API | Struct with closure (`PDFStreamCompression`) | No protocols, no enums; `inout` output matches RFC APIs |
| Flate compression | Optional `ISO 32000 Flate` target | Core target compiles without RFC 1950/1951 |
| Integer type | `Int64` not `Int` | Platform-independent |
| Real number formatting | `swift-numeric-formatting-standard` | Foundation-free `.formatted()` API |
| StringValue storage | `[UnicodeScalar]` + Encoding enum | Preserves PDF encoding distinctions |
| Coordinate system | Top-left origin, y-down | Matches HTML/CSS mental model |
| Font metrics | Single source in ISO_32000.Font.Metrics | Prevents measurement drift |
| CSS support | Explicit finite property list | Clear expectations |
| Content stream operators | Internal sealed enum | Canonical serialization, testable |
| String serialization | Escape table + hex/literal switching | PDF spec correctness |

---

## Testing Strategy

Define test strategies before implementation begins to ensure correctness from the start.

All tests use **Swift Testing** framework with parameterized tests where appropriate.

```swift
import Testing
@testable import ISO_32000
```

### A. Byte-for-Byte PDF Equivalence Tests

Generate and validate structure of:
- A minimal PDF (header, empty page, trailer)
- A single-page text PDF
- A two-page PDF

```swift
@Test("Minimal PDF contains required structural elements")
func minimalPDFStructure() {
    let doc = ISO_32000.Document(pages: [.empty(size: .a4)])
    var buffer: [UInt8] = []
    var writer = ISO_32000.Writer()
    writer.write(doc, into: &buffer)

    let pdf = String(decoding: buffer, as: UTF8.self)

    #expect(pdf.hasPrefix("%PDF-1.7"))
    #expect(pdf.contains("/Type /Catalog"))
    #expect(pdf.contains("/Type /Pages"))
    #expect(pdf.contains("/Type /Page"))
    #expect(pdf.contains("xref"))
    #expect(pdf.contains("trailer"))
    #expect(pdf.contains("%%EOF"))
}

@Test("xref offsets point to valid object locations")
func xrefOffsets() {
    // Validate xref byte offsets point to actual "N 0 obj" locations
    // Critical for PDF readers to locate objects
}
```

### B. Operator Serialization Tests

Every PDF content stream operator must have exact expected ASCII output. Uses parameterized tests for comprehensive coverage:

```swift
struct OperatorTestCase: Sendable {
    let op: ContentStream.Operator
    let expected: String
}

extension OperatorTestCase: CustomTestStringConvertible {
    var testDescription: String { expected }
}

@Test("Operator serialization", arguments: [
    OperatorTestCase(op: .saveState, expected: "q"),
    OperatorTestCase(op: .restoreState, expected: "Q"),
    OperatorTestCase(op: .moveTo(x: 100, y: 200), expected: "100 200 m"),
    OperatorTestCase(op: .moveTo(x: 100.5, y: 200), expected: "100.5 200 m"),
    OperatorTestCase(op: .lineTo(x: 300, y: 400), expected: "300 400 l"),
    OperatorTestCase(op: .beginText, expected: "BT"),
    OperatorTestCase(op: .endText, expected: "ET"),
    OperatorTestCase(op: .stroke, expected: "S"),
    OperatorTestCase(op: .fill, expected: "f"),
    OperatorTestCase(op: .closePath, expected: "h"),
    OperatorTestCase(op: .rectangle(x: 0, y: 0, width: 100, height: 50), expected: "0 0 100 50 re"),
    OperatorTestCase(op: .setLineWidth(2.5), expected: "2.5 w"),
    OperatorTestCase(op: .setFillGray(0.5), expected: "0.5 g"),
    OperatorTestCase(op: .setStrokeGray(0.8), expected: "0.8 G"),
    OperatorTestCase(op: .setFillRGB(r: 1, g: 0, b: 0), expected: "1 0 0 rg"),
    OperatorTestCase(op: .setStrokeRGB(r: 0, g: 0, b: 1), expected: "0 0 1 RG"),
])
func operatorSerialization(_ testCase: OperatorTestCase) {
    var buffer: [UInt8] = []
    ContentStream.Operator.serialize(ascii: testCase.op, into: &buffer)
    #expect(String(decoding: buffer, as: UTF8.self) == testCase.expected)
}

@Test("setFont operator serialization")
func setFontOperator() {
    var buffer: [UInt8] = []
    ContentStream.Operator.serialize(ascii: .setFont(name: .helvetica, size: 12), into: &buffer)
    #expect(String(decoding: buffer, as: UTF8.self) == "/Helvetica 12 Tf")
}

@Test("showText operator with escapes")
func showTextWithEscapes() {
    var buffer: [UInt8] = []
    let text = COS.StringValue("Hello (world)")
    ContentStream.Operator.serialize(ascii: .showText(text), into: &buffer)
    #expect(String(decoding: buffer, as: UTF8.self) == "(Hello \\(world\\)) Tj")
}
```

### C. ISO 32000 Name Parsing Tests

Break on invalid input per ISO 32000 7.3.5. Uses parameterized tests for valid and invalid cases:

```swift
@Test("Valid PDF names", arguments: [
    "Type",
    "FontBBox",
    "A",
    "Name123",
    String(repeating: "A", count: 127),  // Max length exactly
])
func validNames(_ input: String) throws {
    #expect(throws: Never.self) {
        _ = try COS.Name(input)
    }
}

struct InvalidNameCase: Sendable {
    let input: String
    let expectedError: COS.Name.Error
    let description: String
}

extension InvalidNameCase: CustomTestStringConvertible {
    var testDescription: String { description }
}

@Test("Invalid PDF names", arguments: [
    InvalidNameCase(input: "", expectedError: .empty, description: "empty string"),
    InvalidNameCase(input: "Foo\0Bar", expectedError: .containsNullByte, description: "null byte"),
    InvalidNameCase(input: "Foo Bar", expectedError: .containsWhitespace, description: "space"),
    InvalidNameCase(input: "Foo\tBar", expectedError: .containsWhitespace, description: "tab"),
    InvalidNameCase(input: "Foo\nBar", expectedError: .containsWhitespace, description: "newline"),
    InvalidNameCase(input: String(repeating: "A", count: 128), expectedError: .tooLong, description: "128 ASCII bytes"),
    InvalidNameCase(input: String(repeating: "日", count: 43), expectedError: .tooLong, description: "43 CJK chars = 129 UTF-8 bytes"),
])
func invalidNames(_ testCase: InvalidNameCase) {
    #expect(throws: testCase.expectedError) {
        _ = try COS.Name(testCase.input)
    }
}

@Test("Name length uses UTF-8 byte count, not character count")
func nameLengthUsesBytes() {
    // "日" is 3 UTF-8 bytes
    // 42 of them = 126 bytes (OK)
    // 43 of them = 129 bytes (too long)
    let valid42 = String(repeating: "日", count: 42)
    #expect(valid42.utf8.count == 126)
    #expect(throws: Never.self) { _ = try COS.Name(valid42) }

    let invalid43 = String(repeating: "日", count: 43)
    #expect(invalid43.utf8.count == 129)
    #expect(throws: COS.Name.Error.tooLong) { _ = try COS.Name(invalid43) }
}
```

### D. Compression Round-Trip Tests

RFC 1951/1950 must be tested across varied inputs:

```swift
@Test("Compression round-trip with various input types", arguments: [
    (description: "empty", input: [UInt8]()),
    (description: "single byte", input: [UInt8(0x42)]),
    (description: "highly compressible", input: [UInt8](repeating: 0x41, count: 10000)),
    (description: "short text", input: Array("Hello, World!".utf8)),
    (description: "PDF header", input: Array("%PDF-1.7\n".utf8)),
])
func compressionRoundTrip(description: String, input: [UInt8]) {
    var compressed: [UInt8] = []
    RFC_1950.compress(input, into: &compressed)

    var decompressed: [UInt8] = []
    let success = RFC_1950.decompress(compressed, into: &decompressed)
    #expect(success)
    #expect(decompressed == input)
}

@Test("Highly compressible data achieves significant compression")
func compressionRatio() {
    let input = [UInt8](repeating: 0x41, count: 10000)
    var compressed: [UInt8] = []
    RFC_1950.compress(input, into: &compressed)

    #expect(compressed.count < input.count / 10, "Expected >90% compression ratio")
}

@Test("All compression levels produce valid output", arguments: [
    RFC_1951.Level.none,
    RFC_1951.Level.fast,
    RFC_1951.Level.balanced,
    RFC_1951.Level.best,
])
func compressionLevels(_ level: RFC_1951.Level) {
    let input = [UInt8](repeating: 0x42, count: 1000)
    var compressed: [UInt8] = []
    RFC_1950.compress(input, into: &compressed, level: level)

    var decompressed: [UInt8] = []
    let success = RFC_1950.decompress(compressed, into: &decompressed)
    #expect(success)
    #expect(decompressed == input)
}

@Test("Random binary data round-trips correctly")
func randomBinaryRoundTrip() {
    var rng = SystemRandomNumberGenerator()
    let input = (0..<1000).map { _ in UInt8.random(in: 0...255, using: &rng) }

    var compressed: [UInt8] = []
    RFC_1950.compress(input, into: &compressed)

    var decompressed: [UInt8] = []
    let success = RFC_1950.decompress(compressed, into: &decompressed)
    #expect(success)
    #expect(decompressed == input)
}
```

### E. Coordinate System Tests

Verify coordinate flipping on various scenarios:

```swift
struct CoordinateTestCase: Sendable {
    let input: (x: Double, y: Double)
    let pageHeight: Double
    let expected: (x: Double, y: Double)
    let description: String
}

extension CoordinateTestCase: CustomTestStringConvertible {
    var testDescription: String { description }
}

@Test("Coordinate transformation from top-left to bottom-left", arguments: [
    CoordinateTestCase(
        input: (0, 0), pageHeight: 842,
        expected: (0, 842),
        description: "top-left corner"
    ),
    CoordinateTestCase(
        input: (595, 842), pageHeight: 842,
        expected: (595, 0),
        description: "bottom-right corner of A4"
    ),
    CoordinateTestCase(
        input: (72, 72), pageHeight: 842,
        expected: (72, 770),
        description: "with 1-inch margin"
    ),
    CoordinateTestCase(
        input: (297.5, 421), pageHeight: 842,
        expected: (297.5, 421),
        description: "center of A4 page"
    ),
])
func coordinateTransformation(_ testCase: CoordinateTestCase) {
    let writer = ISO_32000.Writer()
    let point = PDF.Point(x: testCase.input.x, y: testCase.input.y)
    let transformed = writer.transformToBottomLeft(point, pageHeight: testCase.pageHeight)

    #expect(transformed.x == testCase.expected.x)
    #expect(transformed.y == testCase.expected.y)
}

@Test("Different page sizes", arguments: [
    (name: "A4", width: 595.0, height: 842.0),
    (name: "Letter", width: 612.0, height: 792.0),
    (name: "A3", width: 842.0, height: 1191.0),
])
func pageSizeCoordinates(name: String, width: Double, height: Double) {
    let writer = ISO_32000.Writer()

    // Top-left should map to (0, height)
    let topLeft = writer.transformToBottomLeft(PDF.Point(x: 0, y: 0), pageHeight: height)
    #expect(topLeft.y == height)

    // Bottom-right should map to (width, 0)
    let bottomRight = writer.transformToBottomLeft(PDF.Point(x: width, y: height), pageHeight: height)
    #expect(bottomRight.y == 0)
}
```

### F. Glyph Width and Layout Tests

Validate text measurement consistency:

```swift
@Test("String width calculation for known text", arguments: [
    (text: "Hello", size: 12.0, expectedWidth: 27.336),  // H=722, e=556, l=222, l=222, o=556
    (text: "", size: 12.0, expectedWidth: 0.0),
    (text: "A", size: 10.0, expectedWidth: 6.67),  // A=667 at 1000 units/em
])
func stringWidth(text: String, size: Double, expectedWidth: Double) {
    let metrics = ISO_32000.Font.Standard14.helvetica.metrics
    let width = metrics.stringWidth(text, atSize: size)
    #expect(abs(width - expectedWidth) < 0.01, "Expected \(expectedWidth), got \(width)")
}

@Test("Line wrapping produces lines within available width")
func lineWrapping() {
    let text = PDFText("The quick brown fox jumps over the lazy dog.")
    let context = PDFRenderContext(
        font: .helvetica,
        fontSize: 12,
        availableWidth: 200
    )

    let lines = text.wrapLines(in: context)

    #expect(lines.count > 1, "Should wrap into multiple lines")

    for line in lines {
        let width = context.font.standard14.metrics.stringWidth(line, atSize: context.fontSize)
        #expect(width <= context.availableWidth, "Line '\(line)' exceeds available width")
    }
}
```

### G. HTML Mapping Tests

Check how HTML elements map to PDF primitives:

```swift
@Test("HTML heading elements", arguments: [
    (tag: "h1", expectedSize: 32.0),
    (tag: "h2", expectedSize: 24.0),
    (tag: "h3", expectedSize: 18.72),
    (tag: "h4", expectedSize: 16.0),
    (tag: "h5", expectedSize: 13.28),
    (tag: "h6", expectedSize: 10.72),
])
func headingMapping(tag: String, expectedSize: Double) throws {
    let html = "<\(tag)>Title</\(tag)>"
    let primitives = HTMLElementMapping.convert(html)

    #expect(primitives.count == 1)
    let text = try #require(primitives[0] as? PDFText)
    #expect(text.text == "Title")
    #expect(abs(text.fontSize - expectedSize) < 0.1)
}

@Test("Paragraph mapping")
func paragraphMapping() throws {
    let html = "<p>Hello World</p>"
    let primitives = HTMLElementMapping.convert(html)

    #expect(primitives.count == 1)
    let text = try #require(primitives[0] as? PDFText)
    #expect(text.text == "Hello World")
}

@Test("CSS precedence: inline overrides class")
func cssPrecedence() {
    let html = """
    <style>.blue { color: blue; }</style>
    <p class="blue" style="color: red;">Text</p>
    """
    let computed = HTMLToPDF().computeStyle(for: html)

    #expect(computed.color == PDF.Color.rgb(1, 0, 0), "Inline style should win")
}
```

### H. String Escape Tests

Verify literal string escaping per ISO 32000:

```swift
@Test("Literal string escaping", arguments: [
    (input: "Hello", expected: "(Hello)"),
    (input: "Hello(World)", expected: "(Hello\\(World\\))"),
    (input: "Line1\nLine2", expected: "(Line1\\nLine2)"),
    (input: "Tab\tHere", expected: "(Tab\\tHere)"),
    (input: "Back\\slash", expected: "(Back\\\\slash)"),
    (input: "Nested((parens))", expected: "(Nested\\(\\(parens\\)\\))"),
    (input: "Form\u{0C}feed", expected: "(Form\\ffeed)"),
    (input: "Back\u{08}space", expected: "(Back\\bspace)"),
    (input: "CR\rhere", expected: "(CR\\rhere)"),
])
func literalStringEscapes(input: String, expected: String) {
    var buffer: [UInt8] = []
    let str = COS.StringValue(input)
    buffer.append(contentsOf: str.asLiteral)
    #expect(String(decoding: buffer, as: UTF8.self) == expected)
}

@Test("Hex string serialization")
func hexStringSerialization() {
    let str = COS.StringValue("ABC")
    var buffer: [UInt8] = []
    buffer.append(contentsOf: str.asHexadecimal)
    #expect(String(decoding: buffer, as: UTF8.self) == "<414243>")
}

@Test("Preferred serialization format selection", arguments: [
    (input: "Hello World", expected: COS.StringValue.SerializationFormat.literal),
    (input: "Simple text", expected: .literal),
    (input: "((()))", expected: .hexadecimal),  // >25% parens
    (input: "((((()))))", expected: .hexadecimal),
])
func preferredFormat(input: String, expected: COS.StringValue.SerializationFormat) {
    let str = COS.StringValue(input)
    #expect(str.preferredSerializationFormat == expected)
}

@Test("Binary data prefers hexadecimal format")
func binaryDataFormat() {
    var scalars: [UnicodeScalar] = []
    for byte: UInt8 in 0x00...0x10 {
        scalars.append(UnicodeScalar(byte))
    }
    let str = COS.StringValue(scalars: scalars, encoding: .pdfDocEncoding)
    #expect(str.preferredSerializationFormat == .hexadecimal)
}
```

---

This test plan uses Swift Testing's parameterized tests (`@Test(arguments:)`) to maximize coverage with minimal boilerplate. Each phase should pass its relevant tests before proceeding to the next.
