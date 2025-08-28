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
    var iconName: String?
    
    private var dynamicIconName: String {
        if let iconName = iconName {
            return iconName
        }
        
        // Default icon logic based on trailing text
        guard let text = trailingText else { return "arrowtriangle.up" }
        let cleanText = text.replacingOccurrences(of: "%", with: "").replacingOccurrences(of: "+", with: "")
        
        if let percentage = Double(cleanText) {
            if percentage > 0 {
                return "arrowtriangle.up.fill"
            } else if percentage < 0 {
                return "arrowtriangle.down.fill"
            } else {
                return "arrowtriangle.up"
            }
        }
        return "arrowtriangle.up"
    }
    
    var body: some View {
        HStack {
            Image(systemName: dynamicIconName)
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
