//
//  CategoryChipsGrid.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// A 3-column grid of colour-coded chips showing the six detectable waste categories.
/// Fully static — no external parameters needed.
struct CategoryChipsGrid: View {

    private let categories: [(name: String, icon: String, hue: Double)] = [
        ("Cardboard", "shippingbox.fill", 0.08),
        ("Glass",     "drop.fill",         0.55),
        ("Metal",     "bolt.fill",          0.62),
        ("Paper",     "doc.fill",           0.12),
        ("Plastic",   "bag.fill",           0.45),
        ("Trash",     "trash.fill",         0.95),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DETECTABLE CATEGORIES")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.35))
                .tracking(1.6)

            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 10
            ) {
                ForEach(categories, id: \.name) { item in
                    CategoryChip(name: item.name, icon: item.icon, hue: item.hue)
                }
            }
        }
    }
}

// MARK: - CategoryChip

private struct CategoryChip: View {
    let name: String
    let icon: String
    let hue: Double

    private var chipColor: Color {
        Color(hue: hue, saturation: 0.65, brightness: 0.85)
    }

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(chipColor)

            Text(name)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .frame(maxWidth: .infinity)
        .background(chipColor.opacity(0.09))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(chipColor.opacity(0.22), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    CategoryChipsGrid()
        .padding()
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}
