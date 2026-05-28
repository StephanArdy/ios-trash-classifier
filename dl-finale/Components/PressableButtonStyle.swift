//
//  PressableButtonStyle.swift
//  dl-finale
//
//  Created by stephan on 27/05/26.
//

import SwiftUI

/// A ButtonStyle that applies a subtle scale-down effect on press,
/// giving buttons a tactile "press" feel.
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
