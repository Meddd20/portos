//
//  CardApp.swift
//  portos
//
//  Created by James Silaban on 23/08/25.
//

import SwiftUI

struct CardApp: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Bibit")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            
            Text("Rp8,000,000")
                .font(.title)
                .fontWeight(.bold)
                .monospacedDigit()
            
            Text("8 lot")
                .
            
            
            HStack {
                VStack{
                    Text("Curr. Price")
                    Text("3.800")
                }
                VStack{
                    Text("Avg. Price")
                    Text("3.800")
                }
            }
        }
        .frame(width: .infinity)
        .background(
            Color(.systemGray5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CardApp()
}
