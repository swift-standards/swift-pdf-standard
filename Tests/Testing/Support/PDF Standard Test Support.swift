public import PDF_Standard
public import Test_Snapshot_Primitives

extension Test.Snapshot.Strategy where Value == PDF.Document, Format == [UInt8] {

    public static var pdf: Self {
        Test.Snapshot.Strategy<[UInt8], [UInt8]>(pathExtension: "pdf", diffing: .data)
            .pullback { (doc: PDF.Document) -> [UInt8] in doc.bytes }
    }
}
