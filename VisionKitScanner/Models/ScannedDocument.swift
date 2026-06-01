import SwiftUI

struct ScannedDocument: Identifiable, Equatable {
    let id = UUID()
    var title: String
    var pages: [UIImage]
    var createdAt: Date
    var recognizedText: String = ""
}
