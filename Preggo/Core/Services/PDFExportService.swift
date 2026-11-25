//
//  PDFExportService.swift
//  Preggo
//
//  Renders any SwiftUI view snapshot into a clean black-and-white clinical PDF
//  using ImageRenderer (iOS 16+) and UIGraphicsPDFRenderer.
//
//  The exported PDF is written to the app's temporary directory and can be
//  shared immediately via ShareLink or UIActivityViewController.
//

import SwiftUI
import UIKit
import PDFKit
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - PDFExportService

@MainActor
final class PDFExportService {

    // MARK: - Public API

    /// Renders `content` to a @2x UIImage, desaturates it to a clinical
    /// black-and-white palette, wraps it in a single-page PDF, and writes
    /// the result to the temporary directory.
    ///
    /// - Parameters:
    ///   - content:   The SwiftUI view to render. Should be sized for a standard
    ///                iPhone screen width (390 pt).
    ///   - filename:  Base name for the output file (no extension).
    /// - Returns: A `URL` pointing to the PDF in the temp directory, or `nil`
    ///            if rendering failed.
    func exportToPDF<V: View>(_ content: V, filename: String = "Preggo_ClinicalReport") -> URL? {

        // 1. Render the SwiftUI view to a UIImage at @2x resolution.
        let renderer = ImageRenderer(content:
            content
                .frame(width: 390)
                .background(Color.white)
                .environment(\.colorScheme, .light)
        )
        renderer.scale = 2.0

        guard let colorImage = renderer.uiImage else {
            print("❌ PDFExportService: ImageRenderer produced nil — ensure view is not empty.")
            return nil
        }

        // 2. Desaturate to a professional black-and-white clinical look.
        let finalImage = desaturated(colorImage) ?? colorImage

        // 3. Add a clinical header and render to PDF.
        let pageSize  = CGSize(width: finalImage.size.width, height: finalImage.size.height + 80)
        let pageRect  = CGRect(origin: .zero, size: pageSize)

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)
        let pdfData = pdfRenderer.pdfData { ctx in
            ctx.beginPage()

            let pdfCtx = ctx.cgContext

            // Header background.
            pdfCtx.setFillColor(UIColor.black.cgColor)
            pdfCtx.fill(CGRect(x: 0, y: 0, width: pageSize.width, height: 60))

            // Header text — "PREGGO / Maternal Intelligence" wordmark.
            let headerAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold),
                .foregroundColor: UIColor.white,
                .kern: 4.0
            ]
            let subAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .medium),
                .foregroundColor: UIColor.lightGray,
                .kern: 1.5
            ]
            NSAttributedString(string: "PREGGO", attributes: headerAttrs)
                .draw(at: CGPoint(x: 20, y: 10))
            NSAttributedString(string: "Maternal Intelligence  •  Clinical Report", attributes: subAttrs)
                .draw(at: CGPoint(x: 20, y: 38))

            // Timestamp (right-aligned).
            let dateStr = Date().formatted(date: .long, time: .shortened)
            let dateAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.lightGray
            ]
            let dateSize = (dateStr as NSString).size(withAttributes: dateAttrs)
            (dateStr as NSString).draw(
                at: CGPoint(x: pageSize.width - dateSize.width - 20, y: 38),
                withAttributes: dateAttrs
            )

            // Dashboard snapshot below header.
            finalImage.draw(at: CGPoint(x: 0, y: 60))
        }

        // 4. Write to temp directory and return URL.
        let dateTag = ISO8601DateFormatter().string(from: Date())
            .replacingOccurrences(of: ":", with: "-")
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(filename)_\(dateTag).pdf")

        do {
            try pdfData.write(to: outputURL)
            print("✅ PDFExportService: PDF written to \(outputURL.lastPathComponent)")
            return outputURL
        } catch {
            print("❌ PDFExportService: Failed to write PDF — \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - Private Helpers

    /// Converts a colour UIImage to greyscale using Core Image.
    private func desaturated(_ image: UIImage) -> UIImage? {
        guard let ciInput = CIImage(image: image) else { return nil }

        let filter = CIFilter.colorMonochrome()
        filter.inputImage  = ciInput
        filter.color       = CIColor(red: 0.8, green: 0.8, blue: 0.8)
        filter.intensity   = 1.0

        guard let output = filter.outputImage else { return nil }

        let context = CIContext()
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
