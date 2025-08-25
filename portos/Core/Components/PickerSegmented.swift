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
    let onAdd: () -> Void

    var body: some View {
        HStack() {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 46) {
                    ForEach(titles.indices, id: \.self) { idx in
                        Button(action: {
                            withAnimation {
                                selectedIndex = idx
                            }
                            onChange()
                        }) {
                            VStack {
                                Text(titles[idx])
                                    .font(.system(size: 15, weight: selectedIndex == idx ? .semibold : .regular))
                                    .foregroundColor(selectedIndex == idx ? Color.primaryApp : Color.primaryApp.opacity(0.5))
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(selectedIndex == idx ? Color.primaryApp : .clear)
                            }
                        }
                    }
                }
            }
            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 0.26, green: 0.26, blue: 0.26))
            }
        }
        .frame(height: 34)
    }
}

#Preview {
    PickerSegmented(
        selectedIndex: .constant(0),
        titles: ["All", "Retirement", "Education", "House"],
        onChange: {print("onChange clicked")},
        onAdd: {print("onAdd clicked")}
    )
}
