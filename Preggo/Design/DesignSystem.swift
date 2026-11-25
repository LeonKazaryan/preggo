//
//  DesignSystem.swift
//  Preggo
//
//  Medical/Clinical Luxury design tokens.
//  All colors, typography, and shared modifiers live here so that every
//  screen in the app draws from a single source of truth.
//

import SwiftUI

// MARK: - Color Palette

extension Color {
    /// Deep navy — primary background for navigation bars and dark surfaces.
    static let preggoNavy = Color(hex: "#0D1B2A")

    /// Warm rose — primary CTA, accent, and brand highlight.
    static let preggoRose = Color(hex: "#C9728F")

    /// Off-white warm surface — card and sheet backgrounds.
    static let preggoSurface = Color(hex: "#F8F5F2")

    /// Muted slate — secondary labels, placeholders, and tertiary text.
    static let preggoMuted = Color(hex: "#8E99A4")

    /// Teal-green — normal / healthy trend indicator.
    static let preggoSuccess = Color(hex: "#4CAF82")

    /// Warm orange — elevated / warning trend indicator.
    static let preggoWarning = Color(hex: "#E8845A")

    /// Initialise a `Color` from a CSS hex string such as `"#RRGGBB"`.
    /// Accepts both `"#RRGGBB"` and `"RRGGBB"` forms.
    init(hex: String) {
        let stripped = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: stripped).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int         & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Typography

extension Font {
    /// Large display title — used for screen headers and hero numbers.
    /// 28pt, SF Pro Display, -0.5 tracking.
    static let preggoTitle: Font = .system(
        size: 28,
        weight: .semibold,
        design: .default
    )

    /// Section headline — card titles, modal headers.
    /// 17pt, SF Pro Text, -0.3 tracking.
    static let preggoHeadline: Font = .system(
        size: 17,
        weight: .semibold,
        design: .default
    )

    /// Body copy — narrative text, descriptions, list rows.
    /// 15pt, SF Pro Text, regular weight.
    static let preggoBody: Font = .system(
        size: 15,
        weight: .regular,
        design: .default
    )

    /// Caption — metadata labels, timestamps, badge text.
    /// 12pt, SF Pro Text, medium weight.
    static let preggoCaption: Font = .system(
        size: 12,
        weight: .medium,
        design: .default
    )
}

// MARK: - Card ViewModifier

/// Applies the standard Preggo card appearance:
/// warm surface fill, 16 pt corner radius, and a soft navy shadow.
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.preggoSurface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            // Subtle elevation: navy at 8 % opacity, spread 12 pt, sunk 4 pt.
            .shadow(
                color: Color.preggoNavy.opacity(0.08),
                radius: 12,
                x: 0,
                y: 4
            )
    }
}

extension View {
    /// Convenience wrapper for `CardModifier`.
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
