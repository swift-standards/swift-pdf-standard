//
//  PDF Standard Test Support.swift
//  swift-pdf-standard
//
//  Snapshot strategy for PDF binary comparison.
//

public import PDF_Standard
public import Test_Snapshot_Primitives

// MARK: - PDF Strategy

extension Test.Snapshot.Strategy where Value == PDF.Document, Format == [UInt8] {
    /// Binary PDF snapshot strategy.
    ///
    /// Serializes `PDF.Document` to bytes via `Binary.Serializable`,
    /// producing `.pdf` files for visual inspection and byte-identical
    /// regression comparison.
    public static var pdf: Self {
        Test.Snapshot.Strategy<[UInt8], [UInt8]>(pathExtension: "pdf", diffing: .data)
            .pullback { (doc: PDF.Document) -> [UInt8] in doc.bytes }
    }
}
