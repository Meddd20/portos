//
//  PickerSegmented.swift
//  portos
//
//  Created by Niki Hidayati on 18/08/25.
//

import SwiftUI

struct PickerSegmented: View {
    @Binding var selectedIndex: Int
    let titles: [String]

    var body: some View {
        HStack {
            ForEach(titles.indices, id: \.self) { idx in
                Button {
                    withAnimation {
                        selectedIndex = idx
                    }
                } label: {
                    VStack {
                        Text(titles[idx])
                            .font(selectedIndex == idx ? .system(size: 14, weight: .bold) : .system(size: 14, weight: .regular))
                            .foregroundColor(selectedIndex == idx ? .primary : .gray)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedIndex == idx ? .black : .clear)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    PickerSegmented(
        selectedIndex: .constant(0),
        titles: ["All", "Retirement", "Education", "House"]
    )
}
