//
//  InformationPill.swift
//  portos
//
//  Created by James Silaban on 23/08/25.
//

import SwiftUI

struct InformationPill: View {
    var trailingText: String?
    var additionalText: String?
    var backgroundColor = Color(.systemGray5)
    var fontColor = Color(.systemGray)
    var showBackground = true
    
    
    var body: some View {
        HStack {
            Image(systemName: "triangle.fill")
                .font(.caption)
                .foregroundStyle(fontColor)
            
            HStack(spacing: 0) {
                Text("\(trailingText ?? "-") %")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(fontColor)
                
            }
            
            if let backText = additionalText {
                Text(backText)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(fontColor)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background( showBackground ?
                     Color(backgroundColor)
                     : Color.clear
        )
        .clipShape(
            RoundedRectangle(cornerRadius: showBackground ? 16 : 0)
        )
    }
}

#Preview {
    InformationPill(
        trailingText: "%",
        additionalText: "Rp 10,682,813",
        backgroundColor: Color(.systemGray5),
        fontColor: Color(.systemGray),
        showBackground: true
    )
}
