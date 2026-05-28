//
//  ContentView.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }
            
            Tab("Live", systemImage: "camera.fill") {
                LiveView()
            }
        }
    }
}

#Preview {
    ContentView()
}
