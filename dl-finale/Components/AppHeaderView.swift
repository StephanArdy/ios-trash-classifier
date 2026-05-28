//
//  AppHeaderView.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// The top header row: app logo + name on the left, animated "AI Ready" badge on the right.
struct AppHeaderView: View {

    @State private var animateBadge = false

    var body: some View {
        HStack {
            // Logo + name
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color(hue: 0.38, saturation: 0.7, brightness: 0.55).opacity(0.2))
                        .frame(width: 42, height: 42)

                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hue: 0.38, saturation: 0.6, brightness: 1.0),
                                    Color(hue: 0.47, saturation: 0.7, brightness: 0.85)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("WasteID")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Waste Classifier")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(0.8)
                }
            }

            Spacer()

            // Animated "AI Ready" badge
            HStack(spacing: 5) {
                Circle()
                    .fill(Color(hue: 0.38, saturation: 0.8, brightness: 0.85))
                    .frame(width: 7, height: 7)
                    .scaleEffect(animateBadge ? 1.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.9).repeatForever(autoreverses: true),
                        value: animateBadge
                    )

                Text("AI Ready")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(hue: 0.38, saturation: 0.6, brightness: 0.9))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Color(hue: 0.38, saturation: 0.7, brightness: 0.3).opacity(0.25)
            )
            .overlay(
                Capsule()
                    .stroke(
                        Color(hue: 0.38, saturation: 0.6, brightness: 0.6).opacity(0.35),
                        lineWidth: 1
                    )
            )
            .clipShape(Capsule())
            .onAppear { animateBadge = true }
        }
    }
}

#Preview {
    AppHeaderView()
        .padding()
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}
