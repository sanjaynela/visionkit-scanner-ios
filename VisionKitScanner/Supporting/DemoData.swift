import UIKit

enum DemoData {
    static let recognizedText = """
    Page 1
    VisionKit Scanner
    Receipt No. 1842
    Coffee 4.25
    Notebook 12.99
    Total 17.24

    Page 2
    Follow up
    Export PDF
    Run OCR on every page
    Keep scans local
    """

    static var documents: [ScannedDocument] {
        [
            ScannedDocument(
                title: "Receipt and Notes",
                pages: [
                    makePage(
                        title: "VisionKit Scanner",
                        lines: ["Receipt No. 1842", "Coffee 4.25", "Notebook 12.99", "Total 17.24"]
                    ),
                    makePage(
                        title: "Follow up",
                        lines: ["Export PDF", "Run OCR on every page", "Keep scans local"]
                    )
                ],
                createdAt: Date(timeIntervalSinceNow: -1_800),
                recognizedText: recognizedText
            ),
            ScannedDocument(
                title: "Project Sketch",
                pages: [
                    makePage(
                        title: "App Ideas",
                        lines: ["Receipt scanner", "Business card OCR", "Searchable archive"]
                    )
                ],
                createdAt: Date(timeIntervalSinceNow: -86_400)
            )
        ]
    }

    private static func makePage(title: String, lines: [String]) -> UIImage {
        let size = CGSize(width: 900, height: 1_200)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            UIColor(red: 0.96, green: 0.95, blue: 0.92, alpha: 1).setFill()
            context.fill(CGRect(origin: .zero, size: size))

            UIColor(red: 0.18, green: 0.19, blue: 0.20, alpha: 1).setStroke()
            let border = UIBezierPath(roundedRect: CGRect(x: 42, y: 42, width: 816, height: 1_116), cornerRadius: 18)
            border.lineWidth = 5
            border.stroke()

            draw(title, at: CGPoint(x: 95, y: 115), font: .boldSystemFont(ofSize: 56))

            var y = 240.0
            for line in lines {
                draw(line, at: CGPoint(x: 95, y: y), font: .systemFont(ofSize: 44))
                y += 86
            }

            UIColor(red: 0.78, green: 0.76, blue: 0.70, alpha: 1).setStroke()
            for ruleY in stride(from: 225.0, through: 950.0, by: 86.0) {
                let path = UIBezierPath()
                path.move(to: CGPoint(x: 95, y: ruleY + 58))
                path.addLine(to: CGPoint(x: 805, y: ruleY + 58))
                path.lineWidth = 2
                path.stroke()
            }
        }
    }

    private static func draw(_ string: String, at point: CGPoint, font: UIFont) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1)
        ]

        string.draw(at: point, withAttributes: attributes)
    }
}
