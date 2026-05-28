//
//  CameraManager.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import AVFoundation
import CoreImage

/// Manages the AVCaptureSession for live camera preview (used by the Live tab).
/// Delegates frame-level object detection to `ObjectDetector`.
/// Exposes `onFrame` so `LiveViewModel` can intercept raw sample buffers for classification.
@Observable
class CameraManager: NSObject {

    // MARK: - Observable Properties

    /// The preview layer to embed in a UIView for the Live camera feed.
    var previewLayer: AVCaptureVideoPreviewLayer?

    /// Latest detected objects, updated whenever ObjectDetector posts a result.
    var detectedObjects: [DetectedObject] = []

    /// Whether the capture session is currently running.
    var isRunning: Bool = false

    // MARK: - Frame Hook

    /// Set by LiveViewModel to receive raw CMSampleBuffers for live classification.
    /// Called on the camera background queue — do not update UI directly inside the closure.
    var onFrame: ((CMSampleBuffer) -> Void)? = nil

    // MARK: - Private

    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "com.dl-finale.camera-queue", qos: .userInitiated)
    private let objectDetector = ObjectDetector()
    private var detectionObserver: NSObjectProtocol?

    /// Guards against adding inputs/outputs to the session more than once.
    private var isConfigured = false

    // MARK: - Lifecycle

    override init() {
        super.init()
        subscribeToDetectionResults()
    }

    deinit {
        if let observer = detectionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - Setup

    /// Configures and starts the capture session.
    /// Safe to call multiple times — only configures once; subsequent calls just restart.
    func setupCamera() {
        guard !isConfigured else {
            startCamera()
            return
        }

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            print("CameraManager: no back camera available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }

            if session.canAddOutput(videoOutput) {
                session.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: queue)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = .resizeAspectFill

            isConfigured = true
            startCamera()
        } catch {
            print("CameraManager setup error: \(error.localizedDescription)")
        }
    }

    // MARK: - Public Controls

    /// Starts the capture session on the background queue.
    func startCamera() {
        guard !session.isRunning else { return }
        queue.async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async { self?.isRunning = true }
        }
    }

    /// Stops the capture session on the background queue.
    func stopCamera() {
        guard session.isRunning else { return }
        queue.async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async { self?.isRunning = false }
        }
    }

    // MARK: - Private Helpers

    private func subscribeToDetectionResults() {
        detectionObserver = NotificationCenter.default.addObserver(
            forName: .detectedObjectsUpdated,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let objects = notification.object as? [DetectedObject] else { return }
            self?.detectedObjects = objects
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        // Existing object detection pipeline
        objectDetector.detectObjects(in: pixelBuffer)

        // Hook for live classification (LiveViewModel)
        onFrame?(sampleBuffer)
    }
}
