//
//  AppSettings.swift
//  dl-finale
//
//  Created by AI Assistant on 15/06/26.
//

import SwiftUI

/// Manages the user settings, including the currently active ML model.
@Observable
class AppSettings {
    
    /// The singleton instance for global access.
    static let shared = AppSettings()
    
    enum ModelOption: String, CaseIterable, Identifiable {
        case mobileNet = "MobileNetV2"
        case resNet = "ResNet50"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .mobileNet: return "MobileNetV2 (Fast)"
            case .resNet: return "ResNet50 (Accurate)"
            }
        }
        
        var description: String {
            switch self {
            case .mobileNet: return "Best for real-time camera & low battery usage"
            case .resNet: return "Best for highest classification accuracy"
            }
        }
    }
    
    /// The currently active ML model. Defaults to ResNet50.
    var selectedModel: ModelOption = .resNet
}
