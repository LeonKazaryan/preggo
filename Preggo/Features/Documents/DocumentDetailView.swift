//
//  DocumentDetailView.swift
//  Preggo
//
//  Full-screen zoomable view of a scanned document.
//

import SwiftUI

struct DocumentDetailView: View {

    let document: ScannedDocument
    let store: DocumentStore

    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if let image = store.loadImage(for: document) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
                            MagnificationGesture()
                                .onChanged { value in
                                    scale = max(1, min(value, 5))
                                }
                                .onEnded { _ in
                                    if scale < 1 {
                                        withAnimation(.spring()) { scale = 1; offset = .zero }
                                    }
                                }
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if scale > 1 { offset = value.translation }
                                }
                                .onEnded { _ in
                                    if scale <= 1 {
                                        withAnimation(.spring()) { offset = .zero }
                                    }
                                }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                scale = scale > 1 ? 1 : 2.5
                                offset = .zero
                            }
                        }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.preggoWarning)
                        Text("Image not found")
                            .font(.preggoBody)
                            .foregroundStyle(.white)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(document.label ?? "Document")
                        .font(.preggoHeadline)
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .foregroundStyle(Color.preggoRose)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if let image = store.loadImage(for: document) {
                        ShareLink(item: Image(uiImage: image),
                                  preview: SharePreview(document.label ?? "Document", image: Image(uiImage: image))) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundStyle(Color.preggoRose)
                        }
                    }
                }
            }
        }
    }
}
