//
//  CameraPreviewView.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI
import AVFoundation

/// A SwiftUI wrapper that embeds an `AVCaptureVideoPreviewLayer` into a full-screen UIView.
/// Pass the `CameraManager` whose `previewLayer` should be displayed.
struct CameraPreviewView: UIViewRepresentable {

    let cameraManager: CameraManager

    func makeUIView(context: Context) -> PreviewContainerView {
        PreviewContainerView()
    }

    func updateUIView(_ uiView: PreviewContainerView, context: Context) {
        // Called whenever SwiftUI re-renders — attach the latest preview layer.
        if let layer = cameraManager.previewLayer {
            uiView.attach(previewLayer: layer)
        }
    }

    // MARK: - Container UIView

    /// A plain UIView subclass that manages an `AVCaptureVideoPreviewLayer` as a sublayer,
    /// keeping it sized to fill bounds across all layout passes.
    class PreviewContainerView: UIView {

        private weak var attachedLayer: AVCaptureVideoPreviewLayer?

        /// Attaches the preview layer if it hasn't been attached yet.
        func attach(previewLayer: AVCaptureVideoPreviewLayer) {
            guard attachedLayer !== previewLayer else { return }
            attachedLayer?.removeFromSuperlayer()
            attachedLayer = previewLayer
            previewLayer.frame = bounds
            layer.insertSublayer(previewLayer, at: 0)
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            attachedLayer?.frame = bounds
        }
    }
}
