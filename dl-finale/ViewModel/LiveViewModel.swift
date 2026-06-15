//
//  LiveViewModel.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI
import Vision
import CoreML

/// Drives the Live tab: owns the camera session, runs WasteClassifier on throttled
/// frames via Vision, and exposes classification state for LiveView to bind to.
@Observable
class LiveViewModel {

    // MARK: - Camera

    let cameraManager = CameraManager()

    // MARK: - Classification State

    /// The top predicted waste category, or `nil` when below the confidence threshold.
    var classificationResult: String? = nil

    /// Confidence [0–1] of the top prediction.
    var classificationConfidence: Double = 0.0

    /// True while a Vision request is in-flight.
    var isScanning: Bool = false

    // MARK: - Configuration

    /// Minimum confidence required to surface a result. Below this → "Scanning…"
    let confidenceThreshold: Double = 0.50

    /// Minimum time between classification runs (seconds).
    let classificationInterval: TimeInterval = 0.5

    // MARK: - Private

    private var mobileNetVisionModel: VNCoreMLModel?
    private var resNetVisionModel: VNCoreMLModel?
    private var lastClassificationTime: Date = .distantPast

    // MARK: - Init

    init() {
        setupVisionRequests()
    }

    // MARK: - Setup

    private func setupVisionRequests() {
        if let mobileNet = try? WasteMobileNet(configuration: MLModelConfiguration()).model {
            self.mobileNetVisionModel = try? VNCoreMLModel(for: mobileNet)
        } else {
            print("LiveViewModel: failed to load WasteMobileNet model")
        }
        
        if let resNet = try? WasteResNet(configuration: MLModelConfiguration()).model {
            self.resNetVisionModel = try? VNCoreMLModel(for: resNet)
        } else {
            print("LiveViewModel: failed to load WasteResNet model")
        }
    }

    // MARK: - Lifecycle

    /// Call from LiveView's `.onAppear`. Wires the frame hook and starts the session.
    func startLive() {
        cameraManager.onFrame = { [weak self] sampleBuffer in
            self?.classifyFrame(sampleBuffer)
        }
        cameraManager.setupCamera()
    }

    /// Call from LiveView's `.onDisappear`. Stops the session and removes the frame hook.
    func stopLive() {
        cameraManager.onFrame = nil
        cameraManager.stopCamera()
        isScanning = false
    }

    // MARK: - Private Classification

    /// Throttled classifier — skips frames that arrive before `classificationInterval` elapses.
    /// Called on the camera background queue; all UI mutations dispatched to main.
    private func classifyFrame(_ sampleBuffer: CMSampleBuffer) {
        let now = Date()
        guard now.timeIntervalSince(lastClassificationTime) >= classificationInterval else { return }

        // Determine which Vision model to run based on current selection
        let selectedModel = AppSettings.shared.selectedModel
        let activeModel = (selectedModel == .mobileNet) ? mobileNetVisionModel : resNetVisionModel

        guard let activeModel else { return }

        lastClassificationTime = now

        DispatchQueue.main.async { self.isScanning = true }

        let request = VNCoreMLRequest(model: activeModel) { [weak self] request, error in
            guard let self else { return }

            if let error {
                print("LiveViewModel: Vision request error — \(error.localizedDescription)")
                DispatchQueue.main.async { self.isScanning = false }
                return
            }

            guard let results = request.results as? [VNClassificationObservation],
                  let top = results.first else {
                DispatchQueue.main.async { self.isScanning = false }
                return
            }

            let label      = top.identifier
            let confidence = Double(top.confidence)

            DispatchQueue.main.async {
                self.isScanning = false
                if confidence >= self.confidenceThreshold {
                    self.classificationResult = label
                    self.classificationConfidence = confidence
                } else {
                    self.classificationResult = nil
                    self.classificationConfidence = confidence
                }
            }
        }

        // CenterCrop matches how models were trained
        request.imageCropAndScaleOption = .centerCrop

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("LiveViewModel: handler.perform error — \(error.localizedDescription)")
            DispatchQueue.main.async { self.isScanning = false }
        }
    }
}
