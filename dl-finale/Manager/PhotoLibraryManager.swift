//
//  PhotoLibraryManager.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI
import PhotosUI

/// Manages photo library selection and image decoding.
/// Owned by HomeViewModel and exposed to the view layer via bindings.
@Observable
class PhotoLibraryManager {

    // MARK: - Observable Properties

    /// The item selected from the Photos picker (bound to PhotosPicker).
    var selectedItem: PhotosPickerItem? = nil

    /// The decoded UIImage produced from `selectedItem` after `loadImage()` is called.
    var selectedImage: UIImage? = nil

    // MARK: - Public Methods

    /// Loads and decodes the image from `selectedItem`.
    /// Call this from the ViewModel whenever `selectedItem` changes.
    func loadImage() async {
        guard let item = selectedItem else { return }

        guard let data = try? await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            return
        }

        await MainActor.run {
            self.selectedImage = uiImage
        }
    }

    /// Resets both the picker selection and the decoded image.
    func clearSelection() {
        selectedItem = nil
        selectedImage = nil
    }
}
