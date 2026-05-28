//
//  LiveView.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// The Live tab's root view.
///
/// Presents a fullscreen camera preview with a real-time classification overlay.
/// Starts the camera session on appear and stops it on disappear to preserve battery.
struct LiveView: View {

    @State private var viewModel = LiveViewModel()

    var body: some View {
        ZStack {
            // MARK: Camera Preview (fullscreen)
            Color.black.ignoresSafeArea()

            CameraPreviewView(cameraManager: viewModel.cameraManager)
                .ignoresSafeArea()

            // Loading veil — shown until AVCaptureSession starts running
            if !viewModel.cameraManager.isRunning {
                loadingOverlay
            }

            // MARK: UI Overlay
            VStack(spacing: 0) {
                topBar
                Spacer()
                LiveResultOverlay(
                    result: viewModel.classificationResult,
                    confidence: viewModel.classificationConfidence,
                    isScanning: viewModel.isScanning
                )
            }
        }
        .onAppear  { viewModel.startLive() }
        .onDisappear { viewModel.stopLive() }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Live Mode")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("Real-time waste detection")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()

            // Live / Starting status badge
            statusBadge
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 20)
        .background(
            LinearGradient(
                colors: [.black.opacity(0.65), .clear],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(viewModel.cameraManager.isRunning
                      ? Color(hue: 0.38, saturation: 0.8, brightness: 0.85)
                      : Color.orange)
                .frame(width: 7, height: 7)

            Text(viewModel.cameraManager.isRunning ? "Live" : "Starting")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.3), value: viewModel.cameraManager.isRunning)
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()

            VStack(spacing: 14) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.3)

                Text("Starting camera…")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.65))
            }
        }
        .transition(.opacity)
        .animation(.easeOut(duration: 0.3), value: viewModel.cameraManager.isRunning)
    }
}

#Preview {
    LiveView()
}
