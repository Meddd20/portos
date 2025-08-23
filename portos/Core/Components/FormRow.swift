//
//  FormRow.swift
//  portos
//
//  Created by Medhiko Biraja on 21/08/25.
//

import Foundation
import SwiftUI

struct FormRow<Content: View>: View {
    let label: String
    let content: () -> Content
    
    init(label: String, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(.primary)
                .backgroundStyle(.black)
                .frame(width: 130, height: 30, alignment: .leading)
                            
            content()
                .padding(.horizontal, 24)
        }
    }
}
