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
    let onChange: () -> Void

    var body: some View {
        HStack {
            ForEach(titles.indices, id: \.self) { idx in
                Button(action: {
                    withAnimation {
                        selectedIndex = idx
                    }
                    onChange()
                }) {
                    VStack {
                        Text(titles[idx])
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(selectedIndex == idx ? .primary : .gray)
                            .lineLimit(1)
                            .truncationMode(.tail)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(selectedIndex == idx ? .black : .clear)
                    }
                }.frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    PickerSegmented(
        selectedIndex: .constant(0),
        titles: ["All", "Retirement", "Education", "House"],
        onChange: {print("onChange clicked")}
    )
}
