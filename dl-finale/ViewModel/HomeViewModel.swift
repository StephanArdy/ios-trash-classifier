//
//  HomeViewModel.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI
import PhotosUI
import CoreML

/// The single source of truth for HomeView.
/// Coordinates PhotoLibraryManager and CameraManager, and exposes
/// clean state properties for each component to bind to.
@Observable
class HomeViewModel {

    // MARK: - Child Managers

    /// Manages photo library selection. Exposed so HomeView can bind
    /// its selectedItem directly to PhotosPicker.
    let photoLibraryManager = PhotoLibraryManager()

    /// Manages the live camera session (used by the Live tab).
    let cameraManager = CameraManager()

    // MARK: - View State

    /// The image currently loaded for classification (from library or camera).
    private(set) var selectedImage: UIImage? = nil

    /// Controls the camera capture sheet on the Home tab.
    var showCamera: Bool = false

    /// True while the ML model is running.
    var isAnalyzing: Bool = false

    /// The predicted waste category label, e.g. "cardboard".
    var classificationResult: String? = nil

    /// Confidence score [0–1] for the top predicted class.
    var classificationConfidence: Double = 0.0

    // MARK: - Private — ML Models

    private let mobileNetClassifier: WasteMobileNet? = {
        let config = MLModelConfiguration()
        return try? WasteMobileNet(configuration: config)
    }()

    private let resNetClassifier: WasteResNet? = {
        let config = MLModelConfiguration()
        return try? WasteResNet(configuration: config)
    }()

    // MARK: - Photo Library

    /// Triggers image decoding from the latest PhotosPickerItem.
    /// Call this from HomeView's `.onChange(of: photoLibraryManager.selectedItem)`.
    func loadPhotoLibraryImage() async {
        await photoLibraryManager.loadImage()
        await MainActor.run {
            self.selectedImage = photoLibraryManager.selectedImage
            self.classificationResult = nil
            self.classificationConfidence = 0.0
        }
    }

    // MARK: - Camera

    /// Sets the image captured via the camera sheet and clears any prior result.
    func setCapturedImage(_ image: UIImage) {
        selectedImage = image
        classificationResult = nil
        classificationConfidence = 0.0
    }

    // MARK: - Classification

    /// Runs the selected model on the current `selectedImage` and updates
    /// `classificationResult` + `classificationConfidence`.
    func classify() async {
        guard let image = selectedImage else { return }

        guard let pixelBuffer = image.toCVPixelBuffer() else {
            print("HomeViewModel: failed to convert image to CVPixelBuffer")
            return
        }

        await MainActor.run { isAnalyzing = true }

        do {
            let label: String
            let confidence: Double

            switch AppSettings.shared.selectedModel {
            case .mobileNet:
                guard let mobileNetClassifier else {
                    throw NSError(domain: "HomeViewModel", code: 1, userInfo: [NSLocalizedDescriptionKey: "WasteMobileNet model not available"])
                }
                let output = try mobileNetClassifier.prediction(image: pixelBuffer)
                label = output.classLabel
                confidence = output.classLabel_probs[label] ?? 0.0
                
            case .resNet:
                guard let resNetClassifier else {
                    throw NSError(domain: "HomeViewModel", code: 2, userInfo: [NSLocalizedDescriptionKey: "WasteResNet model not available"])
                }
                let output = try resNetClassifier.prediction(image: pixelBuffer)
                label = output.classLabel
                confidence = output.classLabel_probs[label] ?? 0.0
            }

            await MainActor.run {
                isAnalyzing = false
                classificationResult = label
                classificationConfidence = confidence
            }
        } catch {
            print("HomeViewModel: classification error — \(error.localizedDescription)")
            await MainActor.run { isAnalyzing = false }
        }
    }

    // MARK: - Reset

    /// Clears only the classification result and confidence.
    func clearResultOnly() {
        classificationResult = nil
        classificationConfidence = 0.0
    }

    /// Clears the selected image, result, and photo library selection.
    func clearImage() {
        selectedImage = nil
        classificationResult = nil
        classificationConfidence = 0.0
        photoLibraryManager.clearSelection()
    }
}
