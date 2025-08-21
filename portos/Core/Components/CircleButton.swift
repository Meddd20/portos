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
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: systemName)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(.black)
                }
                Text(title)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    CircleButton(systemName: "square.and.arrow.up", title: "try", action: {})
}
