import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: ScannerViewModel
    private let shouldShowDemoDetail: Bool
    private let shouldShowDemoOCR: Bool

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        let shouldLoadDemoData = arguments.contains("--demo-data")
            || arguments.contains("--demo-detail")
            || arguments.contains("--demo-ocr")
        shouldShowDemoDetail = arguments.contains("--demo-detail")
        shouldShowDemoOCR = arguments.contains("--demo-ocr")
        _viewModel = StateObject(
            wrappedValue: ScannerViewModel(documents: shouldLoadDemoData ? DemoData.documents : [])
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if (shouldShowDemoDetail || shouldShowDemoOCR), let document = viewModel.documents.first {
                    ScanDetailView(
                        document: document,
                        shouldScrollToOCR: shouldShowDemoOCR,
                        onRecognizedTextChanged: { recognizedText in
                            viewModel.updateRecognizedText(recognizedText, for: document)
                        }
                    )
                } else if viewModel.documents.isEmpty {
                    emptyState
                } else {
                    documentList
                }
            }
            .navigationTitle("VisionKit Scanner")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showScanner()
                    } label: {
                        Label("Scan", systemImage: "camera.viewfinder")
                    }
                    .disabled(!viewModel.canScanDocuments)
                }
            }
            .sheet(isPresented: $viewModel.isShowingScanner) {
                DocumentScannerView(
                    onScanComplete: { images in
                        viewModel.addScannedImages(images)
                        viewModel.hideScanner()
                    },
                    onCancel: {
                        viewModel.hideScanner()
                    },
                    onError: { error in
                        viewModel.scannerErrorMessage = error.localizedDescription
                        viewModel.hideScanner()
                    }
                )
            }
            .alert(
                "Scanner Unavailable",
                isPresented: Binding(
                    get: { viewModel.scannerErrorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.scannerErrorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.scannerErrorMessage ?? "Try again on a real device with camera access.")
            }
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Scans Yet", systemImage: "doc.viewfinder")
        } description: {
            Text("Scan a document, preview its pages, run OCR, and export a PDF from one place.")
        } actions: {
            Button {
                viewModel.showScanner()
            } label: {
                Label("Scan Document", systemImage: "camera.viewfinder")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canScanDocuments)
        }
    }

    private var documentList: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lock.shield")
                        .foregroundStyle(.blue)
                        .frame(width: 28, height: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Local-first scanner")
                            .font(.subheadline.weight(.semibold))

                        Text("Scans stay on the device unless you export and share a PDF.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section {
                ForEach(viewModel.documents) { document in
                    NavigationLink {
                        ScanDetailView(
                            document: document,
                            shouldScrollToOCR: false,
                            onRecognizedTextChanged: { recognizedText in
                                viewModel.updateRecognizedText(recognizedText, for: document)
                            }
                        )
                    } label: {
                        DocumentRow(document: document)
                    }
                }
                .onDelete(perform: viewModel.deleteDocuments)
            } footer: {
                Text("Swipe to delete a scan from this list.")
            }
        }
    }
}

private struct DocumentRow: View {
    let document: ScannedDocument

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "doc.text.viewfinder")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 5) {
                Text(document.title)
                    .font(.headline)

                Text("\(document.pages.count) page\(document.pages.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(document.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !document.recognizedText.isEmpty {
                Image(systemName: "text.viewfinder")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("OCR complete")
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ContentView()
}
