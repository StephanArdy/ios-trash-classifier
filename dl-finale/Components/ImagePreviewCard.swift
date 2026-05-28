//
//  ImagePreviewCard.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// A 290pt tall rounded card that displays either a selected/captured image
/// or an animated placeholder when no image is available.
struct ImagePreviewCard: View {

    /// The image to display. Pass `nil` to show the placeholder state.
    let image: UIImage?

    @State private var pulseRing = false

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 26)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 26)
                        .stroke(
                            image != nil
                                ? Color(hue: 0.38, saturation: 0.6, brightness: 0.7).opacity(0.5)
                                : Color.white.opacity(0.1),
                            lineWidth: 1.2
                        )
                )

            if let image {
                selectedImageView(image)
                    .transition(.scale(scale: 0.92).combined(with: .opacity))
            } else {
                placeholderView
            }
        }
        .frame(height: 290)
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: image != nil)
    }

    // MARK: - Selected State

    private func selectedImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 290)
            .clipShape(RoundedRectangle(cornerRadius: 26))
            // Gradient overlay for depth
            .overlay(
                RoundedRectangle(cornerRadius: 26)
                    .fill(
                        LinearGradient(
                            colors: [.black.opacity(0.28), .clear, .clear, .black.opacity(0.18)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            // Checkmark badge (top-right)
            .overlay(
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
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
                            .shadow(color: .black.opacity(0.4), radius: 6)
                            .padding(14)
                    }
                    Spacer()
                }
            )
    }

    // MARK: - Placeholder State

    private var placeholderView: some View {
        VStack(spacing: 18) {
            // Pulsing concentric rings + icon
            ZStack {
                Circle()
                    .stroke(
                        Color(hue: 0.38, saturation: 0.6, brightness: 0.7).opacity(0.15),
                        lineWidth: 1.5
                    )
                    .frame(width: pulseRing ? 120 : 90)
                    .opacity(pulseRing ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.8).repeatForever(autoreverses: false),
                        value: pulseRing
                    )

                Circle()
                    .stroke(
                        Color(hue: 0.38, saturation: 0.6, brightness: 0.7).opacity(0.1),
                        lineWidth: 1
                    )
                    .frame(width: pulseRing ? 150 : 90)
                    .opacity(pulseRing ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.8).delay(0.3).repeatForever(autoreverses: false),
                        value: pulseRing
                    )

                Circle()
                    .fill(Color(hue: 0.38, saturation: 0.7, brightness: 0.3).opacity(0.25))
                    .frame(width: 80, height: 80)

                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 34, weight: .light))
                    .foregroundColor(Color(hue: 0.38, saturation: 0.5, brightness: 0.8))
            }
            .onAppear { pulseRing = true }

            // Helper text
            VStack(spacing: 6) {
                Text("No Image Selected")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))

                Text("Take a photo or pick from your library\nto begin waste classification")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.25))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .frame(height: 290)
    }
}

#Preview("Placeholder") {
    ImagePreviewCard(image: nil)
        .padding()
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}
