//
//  ModelSelectorView.swift
//  dl-finale
//
//  Created by AI Assistant on 15/06/26.
//

import SwiftUI

/// A custom, premium-styled segmented control to switch between ML models.
struct ModelSelectorView: View {
    
    @State private var settings = AppSettings.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("MODEL ENGINE")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.4))
                .tracking(1.2)
                .padding(.horizontal, 4)
            
            HStack(spacing: 4) {
                ForEach(AppSettings.ModelOption.allCases) { option in
                    VStack(spacing: 2) {
                        Text(option.displayName)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(settings.selectedModel == option ? .white : .white.opacity(0.5))
                        
                        Text(option.description)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(settings.selectedModel == option ? .white.opacity(0.7) : .white.opacity(0.3))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(settings.selectedModel == option 
                                  ? Color(red: 0.12, green: 0.15, blue: 0.22) 
                                  : Color.clear)
                    )
                    .contentShape(Rectangle()) // Make the entire block region tappable
                    .onTapGesture {
                        print("ModelSelectorView: tapped \(option.displayName)")
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            settings.selectedModel = option
                        }
                    }
                }
            }
            .padding(4)
            .background(Color(red: 0.07, green: 0.08, blue: 0.12))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ModelSelectorView()
        .padding()
        .background(Color(red: 0.05, green: 0.06, blue: 0.09))
}
