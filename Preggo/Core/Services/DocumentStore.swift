//
//  DocumentStore.swift
//  Preggo
//
//  Manages scanned document images on local disk.
//  Images saved as JPEGs in Documents/Scans/.
//  Metadata array persisted to UserDefaults.
//

import Foundation
import UIKit
import Observation

@Observable
@MainActor
final class DocumentStore {

    // MARK: - State

    var documents: [ScannedDocument] = []

    // MARK: - Init

    init() {
        ensureDirectoryExists()
        documents = Self.loadMetadata()
    }

    // MARK: - Public API

    /// Saves a UIImage as a JPEG and returns the created ScannedDocument.
    @discardableResult
    func saveImage(_ image: UIImage, label: String? = nil) -> ScannedDocument {
        let doc = ScannedDocument(label: label)

        // Compress and resize for reasonable storage / API payload size.
        let resized = image.resizedToMaxWidth(1200)
        if let data = resized.jpegData(compressionQuality: 0.8) {
            let url = scansDirectory.appendingPathComponent(doc.imageFileName)
            try? data.write(to: url)
        }

        // Generate thumbnail.
        let thumb = image.resizedToMaxWidth(300)
        if let thumbData = thumb.jpegData(compressionQuality: 0.7) {
            let thumbURL = thumbsDirectory.appendingPathComponent(doc.imageFileName)
            try? thumbData.write(to: thumbURL)
        }

        documents.insert(doc, at: 0)
        saveMetadata()
        return doc
    }

    /// Loads the full-size image from disk.
    func loadImage(for document: ScannedDocument) -> UIImage? {
        let url = scansDirectory.appendingPathComponent(document.imageFileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// Loads the thumbnail from disk.
    func loadThumbnail(for document: ScannedDocument) -> UIImage? {
        let url = thumbsDirectory.appendingPathComponent(document.imageFileName)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    /// Returns JPEG data for all documents (for Gemini multimodal API).
    /// Limited to the most recent N documents, compressed for API payload.
    func imageDataForAnalysis(limit: Int = 5) -> [Data] {
        let recent = documents.prefix(limit)
        return recent.compactMap { doc in
            let url = scansDirectory.appendingPathComponent(doc.imageFileName)
            guard let image = UIImage(contentsOfFile: url.path) else { return nil }
            let resized = image.resizedToMaxWidth(1024)
            return resized.jpegData(compressionQuality: 0.6)
        }
    }

    /// Updates a document's label.
    func updateLabel(for documentId: String, label: String?) {
        guard let idx = documents.firstIndex(where: { $0.id == documentId }) else { return }
        documents[idx].label = label
        saveMetadata()
    }

    /// Deletes a document and its images from disk.
    func delete(_ document: ScannedDocument) {
        let imageURL = scansDirectory.appendingPathComponent(document.imageFileName)
        let thumbURL = thumbsDirectory.appendingPathComponent(document.imageFileName)
        try? FileManager.default.removeItem(at: imageURL)
        try? FileManager.default.removeItem(at: thumbURL)
        documents.removeAll { $0.id == document.id }
        saveMetadata()
    }

    // MARK: - Private

    private var scansDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Scans", isDirectory: true)
    }

    private var thumbsDirectory: URL {
        scansDirectory.appendingPathComponent("thumbs", isDirectory: true)
    }

    private func ensureDirectoryExists() {
        let fm = FileManager.default
        try? fm.createDirectory(at: scansDirectory, withIntermediateDirectories: true)
        try? fm.createDirectory(at: thumbsDirectory, withIntermediateDirectories: true)
    }

    private static let metadataKey = "preggo.scannedDocuments"

    private func saveMetadata() {
        guard let data = try? JSONEncoder().encode(documents) else { return }
        UserDefaults.standard.set(data, forKey: Self.metadataKey)
    }

    private static func loadMetadata() -> [ScannedDocument] {
        guard let data = UserDefaults.standard.data(forKey: metadataKey),
              let docs = try? JSONDecoder().decode([ScannedDocument].self, from: data)
        else { return [] }
        return docs
    }
}

// MARK: - UIImage Resize Helper

extension UIImage {
    func resizedToMaxWidth(_ maxWidth: CGFloat) -> UIImage {
        guard size.width > maxWidth else { return self }
        let scale = maxWidth / size.width
        let newSize = CGSize(width: maxWidth, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
