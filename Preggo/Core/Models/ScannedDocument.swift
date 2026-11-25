//
//  ScannedDocument.swift
//  Preggo
//
//  Metadata for a scanned document image. The actual JPEG is stored
//  on disk at Documents/Scans/{id}.jpg — this struct holds the pointer.
//

import Foundation

struct ScannedDocument: Identifiable, Codable, Hashable {
    let id: String
    let imageFileName: String
    let scannedAt: Date
    var label: String?

    init(label: String? = nil) {
        let uuid = UUID().uuidString
        self.id = uuid
        self.imageFileName = "\(uuid).jpg"
        self.scannedAt = Date()
        self.label = label
    }
}
