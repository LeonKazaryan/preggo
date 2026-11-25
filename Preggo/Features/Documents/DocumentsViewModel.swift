//
//  DocumentsViewModel.swift
//  Preggo
//

import Foundation
import UIKit
import Observation

@Observable
@MainActor
final class DocumentsViewModel {

    var showScanner: Bool = false
    var selectedDocument: ScannedDocument? = nil
    var documentToRename: ScannedDocument? = nil
    var renameText: String = ""

    var documentStore: DocumentStore?

    func onScanned(images: [UIImage]) {
        guard let store = documentStore else { return }
        for image in images {
            store.saveImage(image)
        }
        showScanner = false
    }

    func delete(_ document: ScannedDocument) {
        documentStore?.delete(document)
    }

    func startRename(_ document: ScannedDocument) {
        renameText = document.label ?? ""
        documentToRename = document
    }

    func commitRename() {
        guard let doc = documentToRename else { return }
        let trimmed = renameText.trimmingCharacters(in: .whitespaces)
        documentStore?.updateLabel(for: doc.id, label: trimmed.isEmpty ? nil : trimmed)
        documentToRename = nil
    }
}
