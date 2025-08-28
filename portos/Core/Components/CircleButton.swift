//
//  CircleButton.swift
//  portos
//
//  Created by Niki Hidayati on 18/08/25.
//

import SwiftUI

struct CircleButton: View {
    let systemName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color.greyApp.opacity(0.35))
                        .frame(width: 48, height: 48)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                            .inset(by: 0.1)
                            .stroke(Color.borderColor.opacity(0.2), lineWidth: 0.2)
                        )
                    Image(systemName: systemName)
                        .foregroundStyle(Color.textPrimary)
                }
                Text(title)
                    .font(.system(size: 15, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CircleButton(systemName: "square.and.arrow.up", title: "try", action: {})
}
