//
//  OptionSheet.swift
//  portos
//
//  Created by James Silaban on 27/08/25.
//

import SwiftUI

struct SelectOption: Identifiable, Hashable {
    let id: String
    let title: String
}

struct OptionSheet: View {
    let title: String
    let navigationTitle: String
    let options: [SelectOption]
    let localizationManager: LocalizationManager
    @Binding var selection: SelectOption
    
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    
    
    private var filtered: [SelectOption] {
        query.isEmpty
        ? options
        : options.filter{ $0.title.localizedCaseInsensitiveContains(query) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(options) { option in
                    HStack {
                        Text(option.title)
                        Spacer()
                        if option == selection {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selection = option
                        if title == "Language" {
                            if let language = Language(rawValue: option.id) {
                                return localizationManager.setLanguage(language)
                                
                            }
                        } else if title == "Currency" {
                            if let currency = Currency(rawValue: option.id) {
                                localizationManager.setCurrency(currency)
                            }
                        }
                        dismiss() // select & close
                    }
                    
                }
            }
            .searchable(text: $query, prompt: "search".localized)
            .navigationTitle(navigationTitle)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            
        }
        
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    
    OptionSheet(
        title: "Language",
        navigationTitle: "language".localized,
        options: [
            SelectOption(id: "en", title: "English"),
            SelectOption(id: "id", title: "Bahasa Indonesia"),
        ],
        localizationManager: LocalizationManager.shared,
        selection: .constant(SelectOption(id: "en", title: "English"))
    )
}
