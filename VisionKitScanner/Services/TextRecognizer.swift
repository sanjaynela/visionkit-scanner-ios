import UIKit
import Vision

final class TextRecognizer {
    func recognizeText(from images: [UIImage]) async throws -> String {
        var pageResults: [String] = []

        for (index, image) in images.enumerated() {
            let text = try await recognizeText(from: image)

            if !text.isEmpty {
                pageResults.append("Page \(index + 1)\n\(text)")
            }
        }

        return pageResults.joined(separator: "\n\n")
    }

    private func recognizeText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            return ""
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                continuation.resume(returning: recognizedStrings.joined(separator: "\n"))
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage)

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
