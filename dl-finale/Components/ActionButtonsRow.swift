//
//  ActionButtonsRow.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI
import PhotosUI

/// A horizontal row containing the Camera and Photo Library action buttons.
///
/// - Parameters:
///   - photoPickerItem: Binding to the PhotosPickerItem managed by the ViewModel.
///   - onCameraTap: Closure called when the Camera button is tapped.
struct ActionButtonsRow: View {

    @Binding var photoPickerItem: PhotosPickerItem?
    let onCameraTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            cameraButton
            libraryButton
        }
    }

    // MARK: - Camera Button

    private var cameraButton: some View {
        Button(action: onCameraTap) {
            buttonLabel(
                icon: "camera.fill",
                title: "Camera",
                gradient: [
                    Color(hue: 0.38, saturation: 0.70, brightness: 0.58),
                    Color(hue: 0.47, saturation: 0.75, brightness: 0.48)
                ],
                shadowHue: 0.38
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Library Button

    private var libraryButton: some View {
        PhotosPicker(selection: $photoPickerItem, matching: .images) {
            buttonLabel(
                icon: "photo.on.rectangle.angled",
                title: "Library",
                gradient: [
                    Color(hue: 0.60, saturation: 0.60, brightness: 0.68),
                    Color(hue: 0.65, saturation: 0.70, brightness: 0.55)
                ],
                shadowHue: 0.62
            )
        }
        .buttonStyle(PressableButtonStyle())
    }

    // MARK: - Shared Label Builder

    private func buttonLabel(
        icon: String,
        title: String,
        gradient: [Color],
        shadowHue: Double
    ) -> some View {
        HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
            Text(title)
                .font(.system(size: 16, weight: .semibold))
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 54)
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: Color(hue: shadowHue, saturation: 0.6, brightness: 0.5).opacity(0.45),
            radius: 12, y: 5
        )
    }
}

#Preview {
    ActionButtonsRow(
        photoPickerItem: .constant(nil),
        onCameraTap: {}
    )
    .padding()
    .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}
