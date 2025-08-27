//
//  LocalizedText.swift
//  portos
//
//  Created by James Silaban on 27/08/25.
//

import SwiftUI

extension Text {
    init(localized key: String) {
        self.init(LocalizationManager.shared.localizedString(key))
    }
}

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(self)
    }
}

struct LocalizedText: View {
    let key: String
    @StateObject private var localizationManager = LocalizationManager.shared
    
    var body: some View {
        Text(localizationManager.localizedString(key))
    }
}
