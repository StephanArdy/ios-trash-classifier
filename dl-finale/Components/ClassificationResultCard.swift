//
//  ClassificationResultCard.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// Displays the WasteClassifier output: category icon, label, and an animated confidence bar.
struct ClassificationResultCard: View {

    let label: String
    let confidence: Double

    @State private var animatedConfidence: Double = 0

    // MARK: - Category Metadata

    private struct CategoryInfo {
        let icon: String
        let hue: Double
    }

    private var categoryInfo: CategoryInfo {
        switch label.lowercased() {
        case "cardboard": return CategoryInfo(icon: "shippingbox.fill", hue: 0.08)
        case "glass":     return CategoryInfo(icon: "drop.fill",        hue: 0.55)
        case "metal":     return CategoryInfo(icon: "bolt.fill",         hue: 0.62)
        case "paper":     return CategoryInfo(icon: "doc.fill",          hue: 0.12)
        case "plastic":   return CategoryInfo(icon: "bag.fill",          hue: 0.45)
        default:          return CategoryInfo(icon: "trash.fill",        hue: 0.95)
        }
    }

    private var categoryColor: Color {
        Color(hue: categoryInfo.hue, saturation: 0.65, brightness: 0.85)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 18) {
            headerRow
            confidenceBar
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(categoryColor.opacity(0.35), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeOut(duration: 0.9)) {
                animatedConfidence = confidence
            }
        }
        .onChange(of: label) { _, _ in
            animatedConfidence = 0
            withAnimation(.easeOut(duration: 0.9)) {
                animatedConfidence = confidence
            }
        }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(spacing: 14) {
            // Category icon
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                Image(systemName: categoryInfo.icon)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(categoryColor)
            }

            // Label
            VStack(alignment: .leading, spacing: 3) {
                Text("Detected As")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.35))
                    .tracking(1.2)
                Text(label.capitalized)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }

            Spacer()

            // Confidence percentage badge
            VStack(spacing: 2) {
                Text("\(Int(confidence * 100))%")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(categoryColor)
                Text("conf.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
    }

    // MARK: - Confidence Bar

    private var confidenceBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Confidence")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text(String(format: "%.1f%%", confidence * 100))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(categoryColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.white.opacity(0.07))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 5)
                        .fill(
                            LinearGradient(
                                colors: [
                                    categoryColor.opacity(0.7),
                                    categoryColor
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * animatedConfidence, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ClassificationResultCard(label: "cardboard", confidence: 0.94)
        ClassificationResultCard(label: "plastic",   confidence: 0.72)
        ClassificationResultCard(label: "glass",     confidence: 0.55)
    }
    .padding()
    .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}
