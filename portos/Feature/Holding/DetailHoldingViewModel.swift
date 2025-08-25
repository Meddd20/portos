//
//  DetailHoldingViewModel.swift
//  portos
//
//  Created by Medhiko Biraja on 24/08/25.
//

import Foundation

class DetailHoldingViewModel: ObservableObject {
    let holding: Holding
    
    init(holding: Holding) {
        self.holding = holding
    }
}
