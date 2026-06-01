import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    var onScanComplete: ([UIImage]) -> Void
    var onCancel: () -> Void
    var onError: (Error) -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scannerViewController = VNDocumentCameraViewController()
        scannerViewController.delegate = context.coordinator
        return scannerViewController
    }

    func updateUIViewController(
        _ uiViewController: VNDocumentCameraViewController,
        context: Context
    ) {
        // The VisionKit controller manages its own camera session.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(
            onScanComplete: onScanComplete,
            onCancel: onCancel,
            onError: onError
        )
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let onScanComplete: ([UIImage]) -> Void
        private let onCancel: () -> Void
        private let onError: (Error) -> Void

        init(
            onScanComplete: @escaping ([UIImage]) -> Void,
            onCancel: @escaping () -> Void,
            onError: @escaping (Error) -> Void
        ) {
            self.onScanComplete = onScanComplete
            self.onCancel = onCancel
            self.onError = onError
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFinishWith scan: VNDocumentCameraScan
        ) {
            let scannedPages = (0..<scan.pageCount).map { pageIndex in
                scan.imageOfPage(at: pageIndex)
            }

            controller.dismiss(animated: true) {
                self.onScanComplete(scannedPages)
            }
        }

        func documentCameraViewControllerDidCancel(
            _ controller: VNDocumentCameraViewController
        ) {
            controller.dismiss(animated: true) {
                self.onCancel()
            }
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController,
            didFailWithError error: Error
        ) {
            controller.dismiss(animated: true) {
                self.onError(error)
            }
        }
    }
}
