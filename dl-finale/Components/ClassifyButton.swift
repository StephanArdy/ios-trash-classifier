//
//  ClassifyButton.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// A full-width CTA button for triggering waste classification.
///
/// - Parameters:
///   - isEnabled: Pass `true` when an image is ready to classify.
///   - isAnalyzing: Pass `true` while the ML model is running (shows spinner).
///   - onTap: Closure called when the button is tapped.
struct ClassifyButton: View {

    let isEnabled: Bool
    let isAnalyzing: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                if isAnalyzing {
                    analyzingLabel
                } else {
                    idleLabel
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(
                color: isEnabled
                    ? Color(hue: 0.38, saturation: 0.7, brightness: 0.6).opacity(0.45)
                    : .clear,
                radius: 18, y: 7
            )
        }
        .disabled(!isEnabled || isAnalyzing)
        .buttonStyle(PressableButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isAnalyzing)
    }

    // MARK: - Labels

    private var analyzingLabel: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .black))
                .scaleEffect(0.85)

            Text("Analyzing...")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(0.75))
        }
    }

    private var idleLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.system(size: 17, weight: .bold))
            Text("Classify Waste")
                .font(.system(size: 18, weight: .bold, design: .rounded))
        }
        .foregroundColor(isEnabled ? .black : .white.opacity(0.3))
    }

    // MARK: - Background

    @ViewBuilder
    private var buttonBackground: some View {
        if isEnabled {
            LinearGradient(
                colors: [
                    Color(hue: 0.22, saturation: 0.7, brightness: 1.0),
                    Color(hue: 0.38, saturation: 0.75, brightness: 0.92)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            Color.white.opacity(0.07)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
    }
}

#Preview("Disabled") {
    ClassifyButton(isEnabled: false, isAnalyzing: false, onTap: {})
        .padding()
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}

#Preview("Enabled") {
    ClassifyButton(isEnabled: true, isAnalyzing: false, onTap: {})
        .padding()
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}

#Preview("Analyzing") {
    ClassifyButton(isEnabled: true, isAnalyzing: true, onTap: {})
        .padding()
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}
