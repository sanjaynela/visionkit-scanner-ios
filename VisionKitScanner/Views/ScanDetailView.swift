import SwiftUI

struct ScanDetailView: View {
    let document: ScannedDocument
    var onRecognizedTextChanged: (String) -> Void

    @State private var recognizedText: String
    @State private var isRecognizingText = false
    @State private var errorMessage: String?
    @State private var exportedPDFURL: URL?

    private let textRecognizer = TextRecognizer()

    init(
        document: ScannedDocument,
        onRecognizedTextChanged: @escaping (String) -> Void
    ) {
        self.document = document
        self.onRecognizedTextChanged = onRecognizedTextChanged
        _recognizedText = State(initialValue: document.recognizedText)
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(Array(document.pages.enumerated()), id: \.offset) { index, image in
                    pagePreview(index: index, image: image)
                }

                ocrSection
            }
            .padding(.vertical)
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                sharePDFButton
            }
        }
    }

    private func pagePreview(index: Int, image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Page \(index + 1)")
                .font(.headline)
                .padding(.horizontal)

            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.16), radius: 6, x: 0, y: 3)
                .padding(.horizontal)
        }
    }

    private var ocrSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                Task {
                    await recognizeText()
                }
            } label: {
                if isRecognizingText {
                    ProgressView()
                } else {
                    Label("Recognize Text", systemImage: "text.viewfinder")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isRecognizingText || document.pages.isEmpty)

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }

            if !recognizedText.isEmpty {
                Text("Recognized Text")
                    .font(.headline)

                Text(recognizedText)
                    .font(.body)
                    .textSelection(.enabled)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private var sharePDFButton: some View {
        if let exportedPDFURL {
            ShareLink(item: exportedPDFURL) {
                Label("Share PDF", systemImage: "square.and.arrow.up")
            }
        } else {
            Button {
                createPDF()
            } label: {
                Label("Create PDF", systemImage: "doc.richtext")
            }
        }
    }

    private func recognizeText() async {
        isRecognizingText = true
        errorMessage = nil

        do {
            let text = try await textRecognizer.recognizeText(from: document.pages)
            recognizedText = text.isEmpty ? "No text was recognized in this scan." : text
            onRecognizedTextChanged(recognizedText)
        } catch {
            errorMessage = "Failed to recognize text: \(error.localizedDescription)"
        }

        isRecognizingText = false
    }

    private func createPDF() {
        do {
            exportedPDFURL = try PDFExporter.export(document: document)
        } catch {
            errorMessage = "Failed to create PDF: \(error.localizedDescription)"
        }
    }
}
