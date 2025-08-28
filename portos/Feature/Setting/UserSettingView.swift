//
//  UserSettingView.swift
//  portos
//
//  Created by James Silaban on 26/08/25.
//

import SwiftUI

struct UserSettingView: View {
    @StateObject private var localizationManager = LocalizationManager.shared
    enum ActiveSheet: Identifiable {
        case currency, language
        var id: Int { hashValue }
    }
    
    @State private var activeSheet: ActiveSheet?

    // Add state variables for selections
    @State private var selectedCurrency: SelectOption = SelectOption(
        id: LocalizationManager.shared.currentCurrency.rawValue,
        title: "\(LocalizationManager.shared.currentCurrency.rawValue) (\(LocalizationManager.shared.currentCurrency.symbol))"
    )
    @State private var selectedLanguage: SelectOption = SelectOption(
        id: LocalizationManager.shared.currentLanguage.rawValue,
        title: LocalizationManager.shared.currentLanguage.displayName
    )
    
    // data sources
    private let currencyOptions: [SelectOption] = Currency.allCases.map { currency in
        SelectOption(id: currency.rawValue, title: "\(currency.rawValue) (\(currency.symbol))")
    }
    
    private let languageOptions: [SelectOption] = Language.allCases.map { language in
        SelectOption(id: language.rawValue, title: language.displayName)
    }
    
    var body: some View {
        List{
            Section(header: LocalizedText(key: "general")) {
                // Currency Row
                Button {
                    activeSheet = .currency
                } label: {
                    ValueRow(title: "currency".localized, value: selectedCurrency.title)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
                
                // Language Row
                Button {
                    activeSheet = .language
                } label: {
                    ValueRow(title: "language".localized, value: selectedLanguage.title)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .listRowSpacing(8)
        .scrollContentBackground(.hidden)
        .background(Color.backgroundApp)
        .navigationTitle("settings".localized)
        .toolbarBackground(Color.backgroundApp, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .currency:
                OptionSheet(
                    title: "Currency",
                    navigationTitle: "currency".localized,
                    options: currencyOptions,
                    localizationManager: localizationManager,
                    selection: $selectedCurrency
                )
            case .language:
                OptionSheet(
                    title: "Language",
                    navigationTitle: "language".localized,
                    options: languageOptions,
                    localizationManager: localizationManager,
                    selection: $selectedLanguage

                )
            }
        }
    }
}

struct ValueRow: View {
    let title: String
    var value: String? = nil
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(Color.textPrimary)
            Spacer()
            if let value {
                Text(value)
                    .foregroundStyle(Color.textSecondary)
            }
            Image(systemName: "chevron.right")
                .font(.footnote)
                .foregroundStyle(Color.textTertiary)
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    UserSettingView()
}
