//
//  DocumentsView.swift
//  Preggo
//
//  Documents tab — 2-column grid of scanned document thumbnails.
//  Apple Notes-like scanning experience via VNDocumentCameraViewController.
//

import SwiftUI
import VisionKit

struct DocumentsView: View {

    @Environment(DocumentStore.self) private var documentStore
    @State private var vm = DocumentsViewModel()

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.preggoSurface.ignoresSafeArea()

                if documentStore.documents.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(documentStore.documents) { doc in
                                DocumentThumbnailCard(
                                    document: doc,
                                    store: documentStore
                                )
                                .onTapGesture { vm.selectedDocument = doc }
                                .contextMenu {
                                    Button {
                                        vm.startRename(doc)
                                    } label: {
                                        Label("Rename", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        vm.delete(doc)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(16)
                    }
                }

                // FAB — scan new document
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            vm.showScanner = true
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "doc.viewfinder.fill")
                                    .font(.system(size: 18))
                                Text("Scan Document")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color.preggoRose)
                            .clipShape(Capsule())
                            .shadow(color: Color.preggoRose.opacity(0.35), radius: 12, y: 6)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.preggoNavy, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 1) {
                        Text("DOCUMENTS")
                            .font(.system(size: 18, weight: .bold))
                            .kerning(4)
                            .foregroundStyle(.white)
                        Text("\(documentStore.documents.count) scanned")
                            .font(.preggoCaption)
                            .kerning(1)
                            .foregroundStyle(Color.white.opacity(0.6))
                    }
                }
            }
            .fullScreenCover(isPresented: $vm.showScanner) {
                DocumentScannerView(
                    onScan: { images in
                        vm.documentStore = documentStore
                        vm.onScanned(images: images)
                    },
                    onCancel: { vm.showScanner = false }
                )
                .ignoresSafeArea()
            }
            .sheet(item: $vm.selectedDocument) { doc in
                DocumentDetailView(document: doc, store: documentStore)
            }
            .alert("Rename Document", isPresented: Binding(
                get: { vm.documentToRename != nil },
                set: { if !$0 { vm.documentToRename = nil } }
            )) {
                TextField("Label", text: $vm.renameText)
                Button("Save") { vm.commitRename() }
                Button("Cancel", role: .cancel) { vm.documentToRename = nil }
            }
            .onAppear {
                vm.documentStore = documentStore
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.preggoRose.opacity(0.08))
                    .frame(width: 100, height: 100)
                Image(systemName: "doc.viewfinder")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.preggoRose.opacity(0.5))
            }
            Text("No documents yet")
                .font(.preggoHeadline)
                .foregroundStyle(Color.preggoNavy)
            Text("Scan your lab reports, ultrasound results, or any medical document. Preggo's AI will analyze them for you.")
                .font(.preggoBody)
                .foregroundStyle(Color.preggoMuted)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

// MARK: - Document Thumbnail Card

struct DocumentThumbnailCard: View {
    let document: ScannedDocument
    let store: DocumentStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Thumbnail image
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.preggoNavy.opacity(0.06))

                if let thumb = store.loadThumbnail(for: document) {
                    Image(uiImage: thumb)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    Image(systemName: "doc.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.preggoMuted.opacity(0.4))
                }
            }
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Label and date
            VStack(alignment: .leading, spacing: 2) {
                Text(document.label ?? "Document")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.preggoNavy)
                    .lineLimit(1)
                Text(document.scannedAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.preggoCaption)
                    .foregroundStyle(Color.preggoMuted)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .background(Color.preggoSurface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.preggoNavy.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}
