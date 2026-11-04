# swift-pdf-standard

Use this package when you build PDF files at the level of the ISO 32000 document model: pages, content streams, fonts and resources, with Flate compression available. Start from `PDF.Document`, and from `PDF.Configuration` for page size, margins and default text settings. `PDF` is `ISO_32000` from swift-iso-32000, which this package imports for you along with its Flate support and Geometry. If you would rather write content as HTML views or Markdown, use swift-pdf. If you want to depend on the ISO 32000 implementation directly, use swift-iso-32000.

## Laws

- `PDF.Configuration.content` is the paper size less the margins on both sides, so 72 point margins on US Letter leave 468 by 648 points. `PDF.Configuration.mediaBox` is the paper size itself.
