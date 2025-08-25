//
//  HoldingDetail.swift
//  portos
//
//  Created by James Silaban on 23/08/25.
//

import SwiftUI

struct InvestmentItem: Identifiable {
    var id: String { platform }  // Make `platform` the unique identifier
    
    var platform: String
    var totalValue: Double
    var quantityLabel: String
    var currentPrice: Double
    var averagePrice: Double
}

struct TransactionItem: Identifiable {
    let id = UUID()
    let type: TransactionType
    let lots: Int
    let note: String?             // e.g. "Retirement → Education"
    let amount: Int?              // nil for transfers with no amount shown on right
    let platform: String?         // e.g. "Bibit", "Pintu"
    let date: Date
}

struct HoldingDetail: View {
    @State private var rowHeight: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode
    
    let items: [InvestmentItem] = [
        InvestmentItem(
            platform: "Bibit",
            totalValue: 8_000_000.0,
            quantityLabel: "8 Lot",
            currentPrice: 3_800.0,
            averagePrice: 3_800.0
        ),
        InvestmentItem(
            platform: "AA",
            totalValue: 8_000_000.0,
            quantityLabel: "8 Lot",
            currentPrice: 3_800.0,
            averagePrice: 3_800.0
        )
    ]
    
    var transactionItems: [(title: String, items: [TransactionItem])] {
        let calendar = Calendar.current
        let today = Date()
        let aug22 = calendar.date(from: DateComponents(year: 2025, month: 8, day: 22)) ?? today

        return [
            (
                title: "Today", items: [
                    .init(
                        type: .buy,
                        lots: 100,
                        note: "Rp 3,200",
                        amount: 1_200_000,
                        platform: "Bibit",
                        date: today
                    ),
                    .init(
                        type: .allocateIn,
                        lots: 50,
                        note: "Retirement → Education",
                        amount: 600_000,
                        platform: "Bibit",
                        date: today
                    )
                ]
            ),
            (
                title: "22 August 2025", items: [
                    .init(
                        type: .sell,
                        lots: 10, note: "Rp 3,200",
                        amount: 320_000,
                        platform: "Pintu",
                        date: aug22
                    ),
                    .init(
                        type: .buy,
                        lots: 100,
                        note: "Rp 3,200",
                        amount: 1_200_000,
                        platform: "Bibit",
                        date: aug22
                    ),
                ]
            )
        ]
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                VStack{
                    Text("PT Bank Central Asia Tbk.")
                        .font(.title3)
                        .fontWeight(.none)
                    
                    Text("Rp.100,000,000,-")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    InformationPill(
                        trailingText: "%",
                        backgrounColor: Color.green.opacity(0.15),
                        fontColor: Color(hue: 0.33, saturation: 0.75, brightness: 0.55),
                        showBackground: true
                    )
                }
                .padding(.horizontal, 16)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 16) {
                        ForEach(items) { item in
                            HoldingSummaryCard(
                                platform: item.platform,
                                totalValue: item.totalValue,
                                quantityLabel: item.quantityLabel,
                                currentPrice: item.currentPrice,
                                averagePrice: item.averagePrice,
                                showAmounts: .constant(true)
                            )
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                }
                
                HStack(alignment: .center, spacing: 42) {
                    CircleButton(
                        systemName: "plus",
                        title: "Add",
                        action: {}
                    )
                    CircleButton(
                        systemName: "minus",
                        title: "Liquidate",
                        action: {}
                    )
                    CircleButton(
                        systemName: "arrow.right",
                        title: "Add",
                        action: {}
                    )
                }
                .padding(.horizontal, 16)
                
                // Transaction History
                VStack(alignment: .leading, spacing: 18) {
                    Text("Transactions")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    ForEach(transactionItems, id: \.title) { transaction in
                        Section {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(transaction.title)
                                Divider()
                                    .padding(.top, 4)
                                ForEach(transaction.items) { item in
                                    TransactionRow(transaction: item)
                                }
                            }.padding(.bottom, 32)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .navigationTitle("BBCA")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
            }
        }
    }
}

#Preview {
    HoldingDetail()
}
