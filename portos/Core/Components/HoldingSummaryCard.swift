//
//  HoldingSummaryCard.swift
//  portos
//
//  Created by James Silaban on 23/08/25.
//

import SwiftUI

struct HoldingSummaryCard: View {
    // MARK: Formatting
    private var maskedIDR: String { "••••••••" }
    let platform: String
    let totalValue: Decimal
    let quantityLabel: String
    let currentPrice: Decimal
    let averagePrice: Decimal
    let unit: String
    
    // Mark: Local UI State
    @Binding var showAmounts: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            // Platform
            Text(platform)
                .font(.body)
            
            VStack(alignment: .leading){
                // Amount
                Text(showAmounts ? cashAmount(totalValue) : maskedIDR)
                    .font(.title)
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                // Quantity
                Text("\(quantityLabel) \(unit)")
                    .font(.body)
                    .fontWeight(.regular)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Curr. Price")
                        .font(.subheadline)
                        .fontWeight(.light)
                    Text(cashAmount(currentPrice))
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4){
                    Text("Avg. Price")
                        .font(.subheadline)
                        .fontWeight(.light)
                    Text(cashAmount(averagePrice))
                        .font(.subheadline)
                        .fontWeight(.regular)
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 24)
        .frame(width: 300)
        .background(
            Color.blue.opacity(0.1)
        )
        .clipShape(RoundedRectangle(
            cornerRadius: 28,
            style: .continuous)
        )
    }
}

#Preview {
//    HoldingSummaryCard(
//        platform: "Bibit",
//        totalValue: 8_000_000.0,
//        quantityLabel: "8 Lot",
//        currentPrice: 3_800.0,
//        averagePrice: 3_800.0,
//        unit:
//        showAmounts: .constant(true)
//    )
}
