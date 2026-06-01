# VisionKit Scanner

A small SwiftUI iOS app inspired by the article "I Finally Tried Apple VisionKit: Building a Simple Document Scanner in SwiftUI".

The app shows the practical VisionKit flow:

- Open Apple's native document scanner with `VNDocumentCameraViewController`
- Store scanned pages in SwiftUI state through an MVVM view model
- Preview every scanned page
- Run Vision OCR on scanned images
- Export scanned pages as a PDF

## Requirements

- Xcode 16 or newer
- iOS 17 or newer
- A real iPhone or iPad for camera-based scanning

Camera APIs should be tested on a physical device. The simulator may build the app, but document scanning depends on camera hardware.

## Project Structure

```text
VisionKitScanner/
  Models/
  Services/
  Supporting/
  ViewModels/
  Views/
  VisionKitScannerApp.swift
```

## Privacy

Scanned pages and OCR text stay in memory unless the user exports a PDF through the share sheet. The sample does not upload document data to a server.
