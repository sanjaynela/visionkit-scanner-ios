import UIKit

enum PDFExporter {
    static func export(document: ScannedDocument) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(document.title)
            .appendingPathExtension("pdf")

        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(origin: .zero, size: CGSize(width: 612, height: 792)))

        try renderer.writePDF(to: url) { context in
            for image in document.pages {
                context.beginPage()

                let pageBounds = context.pdfContextBounds
                let imageRect = imageRect(for: image.size, in: pageBounds.insetBy(dx: 24, dy: 24))
                image.draw(in: imageRect)
            }
        }

        return url
    }

    private static func imageRect(for imageSize: CGSize, in bounds: CGRect) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else {
            return bounds
        }

        let widthRatio = bounds.width / imageSize.width
        let heightRatio = bounds.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        let scaledSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)

        return CGRect(
            x: bounds.midX - scaledSize.width / 2,
            y: bounds.midY - scaledSize.height / 2,
            width: scaledSize.width,
            height: scaledSize.height
        )
    }
}
