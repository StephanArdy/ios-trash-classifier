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

    private var vnRequest: VNCoreMLRequest?
    private var lastClassificationTime: Date = .distantPast

    // MARK: - Init

    init() {
        setupVisionRequest()
    }

    // MARK: - Setup

    private func setupVisionRequest() {
        guard let coreMLModel = try? WasteClassifier(configuration: MLModelConfiguration()).model,
              let vnModel = try? VNCoreMLModel(for: coreMLModel) else {
            print("LiveViewModel: failed to build VNCoreMLModel from WasteClassifier")
            return
        }

        let request = VNCoreMLRequest(model: vnModel) { [weak self] request, error in
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

        // CenterCrop matches how MobileNetV2 was trained
        request.imageCropAndScaleOption = .centerCrop
        self.vnRequest = request
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
        guard now.timeIntervalSince(lastClassificationTime) >= classificationInterval,
              let request = vnRequest else { return }

        lastClassificationTime = now

        DispatchQueue.main.async { self.isScanning = true }

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("LiveViewModel: handler.perform error — \(error.localizedDescription)")
            DispatchQueue.main.async { self.isScanning = false }
        }
    }
}
