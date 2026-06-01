import SwiftUI
import VisionKit

@MainActor
final class ScannerViewModel: ObservableObject {
    @Published private(set) var documents: [ScannedDocument] = []
    @Published var isShowingScanner = false
    @Published var scannerErrorMessage: String?

    init(documents: [ScannedDocument] = []) {
        self.documents = documents
    }

    var canScanDocuments: Bool {
        VNDocumentCameraViewController.isSupported
    }

    func showScanner() {
        guard canScanDocuments else {
            scannerErrorMessage = "Document scanning is not available on this device."
            return
        }

        isShowingScanner = true
    }

    func hideScanner() {
        isShowingScanner = false
    }

    func addScannedImages(_ images: [UIImage]) {
        guard !images.isEmpty else {
            return
        }

        let document = ScannedDocument(
            title: "Scan \(documents.count + 1)",
            pages: images,
            createdAt: Date()
        )

        documents.insert(document, at: 0)
    }

    func updateRecognizedText(_ text: String, for document: ScannedDocument) {
        guard let index = documents.firstIndex(where: { $0.id == document.id }) else {
            return
        }

        documents[index].recognizedText = text
    }

    func deleteDocuments(at offsets: IndexSet) {
        documents.remove(atOffsets: offsets)
    }
}
