//
//  HomeView.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI
import PhotosUI

/// The Home tab's root view.
///
/// Acts as a thin coordinator: it owns the HomeViewModel via @State and
/// wires each extracted component to the relevant ViewModel properties.
/// No business logic or styling lives here — all of that is delegated.
struct HomeView: View {

    @State private var viewModel = HomeViewModel()
    @State private var settings = AppSettings.shared

    var body: some View {
        // Force SwiftUI to register HomeView as a dependency for selectedModel updates
        let _ = settings.selectedModel
        
        // @Bindable lets us derive Binding<T> from the @Observable PhotoLibraryManager.
        @Bindable var photoManager = viewModel.photoLibraryManager

        ZStack {
            backgroundLayer

            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    AppHeaderView()

                    ImagePreviewCard(image: viewModel.selectedImage)

                    ActionButtonsRow(
                        photoPickerItem: $photoManager.selectedItem,
                        onCameraTap: { viewModel.showCamera = true }
                    )

                    ClassifyButton(
                        isEnabled: viewModel.selectedImage != nil,
                        isAnalyzing: viewModel.isAnalyzing,
                        onTap: { Task { await viewModel.classify() } }
                    )

                    if let result = viewModel.classificationResult {
                        ClassificationResultCard(
                            label: result,
                            confidence: viewModel.classificationConfidence
                        )
                        .transition(.scale(scale: 0.95).combined(with: .opacity))
                    }


                    CategoryChipsGrid()
                }
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 48)
                .animation(.spring(response: 0.45, dampingFraction: 0.78), value: viewModel.classificationResult)
            }
        }
        // Camera sheet — uses callback to keep CameraPicker free of ViewModel references.
        .sheet(isPresented: $viewModel.showCamera) {
            CameraPicker { capturedImage in
                viewModel.setCapturedImage(capturedImage)
            }
            .ignoresSafeArea()
        }
        // Kick off image decoding whenever the library selection changes.
        .onChange(of: viewModel.photoLibraryManager.selectedItem) { _, _ in
            Task { await viewModel.loadPhotoLibraryImage() }
        }
        // Clear old result when model is switched
        .onChange(of: settings.selectedModel) { oldVal, newVal in
            print("HomeView: model switched from \(oldVal) to \(newVal)")
            viewModel.clearResultOnly()
        }
    }

    // MARK: - Background

    /// Dark ambient background with two subtle glow circles.
    private var backgroundLayer: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.09)
                .ignoresSafeArea()

            Circle()
                .fill(Color(hue: 0.38, saturation: 0.8, brightness: 0.5).opacity(0.12))
                .frame(width: 340)
                .blur(radius: 80)
                .offset(x: -60, y: -160)

            Circle()
                .fill(Color(hue: 0.6, saturation: 0.7, brightness: 0.6).opacity(0.08))
                .frame(width: 280)
                .blur(radius: 70)
                .offset(x: 100, y: 200)
        }
    }
}

#Preview {
    HomeView()
}
