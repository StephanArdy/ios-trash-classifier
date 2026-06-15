//
//  SettingsView.swift
//  dl-finale
//
//  Created by AI Assistant on 15/06/26.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var settings = AppSettings.shared
    
    var body: some View {
        ZStack {
            backgroundLayer
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    // Header
                    headerView
                    
                    // Model Selection Box
                    modelSelectionSection
                    
                    // Model Comparison Card
                    modelComparisonCard
                    
                    // About Section
                    aboutSection
                    
                    Spacer()
                }
                .padding(.horizontal, 22)
                .padding(.top, 24)
                .padding(.bottom, 30)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Configure app engine and model options")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.4))
        }
    }
    
    // MARK: - Model Selection Section
    
    private var modelSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ACTIVE CLASSIFICATION ENGINE")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .tracking(1.2)
                .padding(.horizontal, 4)
            
            VStack(spacing: 12) {
                ForEach(AppSettings.ModelOption.allCases) { option in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(option.displayName)
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(settings.selectedModel == option ? .white : .white.opacity(0.6))
                            
                            Spacer()
                            
                            if settings.selectedModel == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(hue: 0.38, saturation: 0.6, brightness: 1.0),
                                                Color(hue: 0.47, saturation: 0.7, brightness: 0.85)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            } else {
                                Circle()
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                    .frame(width: 20, height: 20)
                            }
                        }
                        
                        Text(option.description)
                            .font(.system(size: 12))
                            .foregroundColor(settings.selectedModel == option ? .white.opacity(0.7) : .white.opacity(0.35))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(settings.selectedModel == option 
                                  ? Color(red: 0.12, green: 0.15, blue: 0.22) 
                                  : Color.white.opacity(0.03))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(settings.selectedModel == option 
                                    ? Color(hue: 0.38, saturation: 0.6, brightness: 0.6).opacity(0.3)
                                    : Color.white.opacity(0.06), 
                                    lineWidth: 1)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            settings.selectedModel = option
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Model Comparison Card
    
    private var modelComparisonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("ENGINE COMPARISON")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .tracking(1.2)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                // Table Header
                HStack {
                    Text("Metric")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 80, alignment: .leading)
                    Spacer()
                    Text("MobileNet")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 90, alignment: .trailing)
                    Spacer()
                    Text("ResNet50")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 90, alignment: .trailing)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                
                Divider().background(Color.white.opacity(0.08))
                
                // Rows
                comparisonRow(metric: "Accuracy", val1: "82.6%", val2: "91.8%", isBest2: true)
                comparisonRow(metric: "File Size", val1: "4.5 MB", val2: "49.2 MB", isBest1: true)
                comparisonRow(metric: "Speed", val1: "Ultra Fast", val2: "Fast", isBest1: true)
                comparisonRow(metric: "Battery Use", val1: "Low", val2: "Medium", isBest1: true)
            }
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
    
    private func comparisonRow(metric: String, val1: String, val2: String, isBest1: Bool = false, isBest2: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(metric)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 80, alignment: .leading)
                Spacer()
                Text(val1)
                    .font(.system(size: 13, weight: isBest1 ? .bold : .semibold, design: .rounded))
                    .foregroundColor(isBest1 ? Color(hue: 0.38, saturation: 0.7, brightness: 0.9) : .white.opacity(0.6))
                    .frame(width: 90, alignment: .trailing)
                Spacer()
                Text(val2)
                    .font(.system(size: 13, weight: isBest2 ? .bold : .semibold, design: .rounded))
                    .foregroundColor(isBest2 ? Color(hue: 0.38, saturation: 0.7, brightness: 0.9) : .white.opacity(0.6))
                    .frame(width: 90, alignment: .trailing)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            
            Divider().background(Color.white.opacity(0.05))
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ABOUT THIS APP")
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.45))
                .tracking(1.2)
                .padding(.horizontal, 4)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("WasteID Classifier")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("This app evaluates waste images across 6 classes (cardboard, glass, metal, paper, plastic, trash) using deep neural networks. Built with PyTorch and CoreML.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.45))
                    .lineSpacing(3)
                
                Divider().padding(.vertical, 4).background(Color.white.opacity(0.05))
                
                HStack {
                    Text("App Version")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                    Text("2.0.0")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            .padding(18)
            .background(Color.white.opacity(0.03))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Background Layer
    
    private var backgroundLayer: some View {
        ZStack {
            Color(red: 0.05, green: 0.06, blue: 0.09)
                .ignoresSafeArea()
            
            Circle()
                .fill(Color(hue: 0.38, saturation: 0.8, brightness: 0.5).opacity(0.07))
                .frame(width: 320)
                .blur(radius: 80)
                .offset(x: -80, y: -200)
            
            Circle()
                .fill(Color(hue: 0.6, saturation: 0.7, brightness: 0.6).opacity(0.05))
                .frame(width: 260)
                .blur(radius: 70)
                .offset(x: 120, y: 180)
        }
    }
}

#Preview {
    SettingsView()
}
