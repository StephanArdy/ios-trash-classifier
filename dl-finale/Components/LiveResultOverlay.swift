//
//  LiveResultOverlay.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// Bottom overlay card for the Live tab.
/// Shows an animated "Scanning…" state when no confident result is available,
/// and a labelled result card with confidence bar when a class is detected.
struct LiveResultOverlay: View {

    /// The top classification label, or `nil` when below the confidence threshold.
    let result: String?

    /// Confidence score [0–1] for the top label.
    let confidence: Double

    /// True while a Vision request is in-flight.
    let isScanning: Bool

    // MARK: - Body

    var body: some View {
        Group {
            if let result {
                resultCard(label: result)
                    .transition(.scale(scale: 0.96).combined(with: .opacity))
            } else {
                scanningCard
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.78), value: result)
        .padding(.horizontal, 20)
        .padding(.bottom, 32)
    }

    // MARK: - Result Card

    private func resultCard(label: String) -> some View {
        let info = categoryInfo(for: label)
        let color = Color(hue: info.hue, saturation: 0.65, brightness: 0.85)

        return ResultCardContent(
            label: label,
            confidence: confidence,
            icon: info.icon,
            color: color
        )
    }

    // MARK: - Scanning Card

    private var scanningCard: some View {
        ScanningCardContent(isScanning: isScanning)
    }

    // MARK: - Category Metadata

    private struct CategoryMeta {
        let icon: String
        let hue: Double
    }

    private func categoryInfo(for label: String) -> CategoryMeta {
        switch label.lowercased() {
        case "cardboard": return CategoryMeta(icon: "shippingbox.fill", hue: 0.08)
        case "glass":     return CategoryMeta(icon: "drop.fill",        hue: 0.55)
        case "metal":     return CategoryMeta(icon: "bolt.fill",         hue: 0.62)
        case "paper":     return CategoryMeta(icon: "doc.fill",          hue: 0.12)
        case "plastic":   return CategoryMeta(icon: "bag.fill",          hue: 0.45)
        default:          return CategoryMeta(icon: "trash.fill",        hue: 0.95)
        }
    }
}

// MARK: - Result Card Content (separate view for animation state)

private struct ResultCardContent: View {
    let label: String
    let confidence: Double
    let icon: String
    let color: Color

    @State private var animatedConfidence: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            // Header row
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 54, height: 54)
                    Image(systemName: icon)
                        .font(.system(size: 25, weight: .semibold))
                        .foregroundColor(color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("DETECTED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .tracking(1.5)
                    Text(label.capitalized)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                Spacer()

                // Confidence badge
                VStack(spacing: 2) {
                    Text("\(Int(confidence * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                    Text("conf.")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            // Animated confidence bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 7)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.65), color],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedConfidence, height: 7)
                }
            }
            .frame(height: 7)
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(color.opacity(0.45), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .onAppear {
            animatedConfidence = 0
            withAnimation(.easeOut(duration: 0.65)) {
                animatedConfidence = confidence
            }
        }
        .onChange(of: label) { _, _ in
            animatedConfidence = 0
            withAnimation(.easeOut(duration: 0.65)) {
                animatedConfidence = confidence
            }
        }
        .onChange(of: confidence) { _, newValue in
            withAnimation(.easeOut(duration: 0.35)) {
                animatedConfidence = newValue
            }
        }
    }
}

// MARK: - Scanning Card Content

private struct ScanningCardContent: View {
    let isScanning: Bool
    @State private var pulseDot = false

    var body: some View {
        HStack(spacing: 16) {
            // Pulsing indicator dots
            HStack(spacing: 5) {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(Color.white.opacity(0.65))
                        .frame(width: 7, height: 7)
                        .scaleEffect(pulseDot ? 1.25 : 0.75)
                        .animation(
                            .easeInOut(duration: 0.55)
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.18),
                            value: pulseDot
                        )
                }
            }
            .onAppear { pulseDot = true }

            VStack(alignment: .leading, spacing: 3) {
                Text("Scanning...")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                Text("Point camera at waste material")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            Image(systemName: "viewfinder")
                .font(.system(size: 26))
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - Preview

#Preview("Scanning") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            LiveResultOverlay(result: nil, confidence: 0, isScanning: true)
        }
    }
}

#Preview("Result — Cardboard") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            LiveResultOverlay(result: "cardboard", confidence: 0.91, isScanning: false)
        }
    }
}

#Preview("Result — Plastic") {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            Spacer()
            LiveResultOverlay(result: "plastic", confidence: 0.63, isScanning: false)
        }
    }
}
