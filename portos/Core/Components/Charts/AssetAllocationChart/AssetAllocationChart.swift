//
//  AssetAllocationChart.swift
//  portos
//
//  Created by Niki Hidayati on 26/08/25.
//

import SwiftUI

// MARK: - Chart (All Groups Aggregated)

struct AssetAllocationAllChart: View {
    let overview: PortfolioOverview
    var maxBarHeight: CGFloat = 241
    var barWidth: CGFloat = 105
    var spacing: CGFloat = 28
    var topN: Int? = nil

    private let topColor  = Color.secondaryApp // beige
    private let fillColor = Color.primaryApp

    struct Allocation: Identifiable {
        let id = UUID()
        let name: String
        let value: Double
        let percent: Double
    }

    private var allocations: [Allocation] {
        // 1) Agregasi nilai per nama AssetItem di semua group
        var sumByAsset: [String: Double] = [:]

        for group in overview.groupItems {
            for item in group.assets {
                let key = (item.name ?? "-").trimmingCharacters(in: .whitespacesAndNewlines)
                let v = Self.parseNumber(item.value) ?? 0
                sumByAsset[key, default: 0] += v
            }
        }

        // 2) Normalisasi ke persen
        let total = sumByAsset.values.reduce(0, +)
        let base: [Allocation] = sumByAsset.map { (name, value) in
            Allocation(name: name, value: value, percent: total > 0 ? value / total : 0)
        }
        .sorted { $0.percent > $1.percent }

        // 3) Optional: ambil top N
        if let n = topN { return Array(base.prefix(n)) }
        return base
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: spacing) {
                ForEach(allocations) { a in
                    AllocationBarView(
                        title: a.name,
                        percent: a.percent,
                        barWidth: barWidth,
                        maxHeight: maxBarHeight,
                        topColor: topColor,
                        fillColor: fillColor
                    )
                }
            }
            .padding(.horizontal, 8)
        }
    }

    // MARK: - parser
    private static func parseNumber(_ text: String?) -> Double? {
        guard var s = text?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return nil }

        s = s.unicodeScalars
            .filter { CharacterSet(charactersIn: "0123456789.,").contains($0) }
            .map(String.init).joined()

        let hasComma = s.contains(",")
        let hasDot   = s.contains(".")

        let thousandsID = try! NSRegularExpression(pattern: #"^\d{1,3}(\.\d{3})+$"#)

        func matches(_ regex: NSRegularExpression, _ str: String) -> Bool {
            regex.firstMatch(in: str, range: NSRange(location: 0, length: str.utf16.count)) != nil
        }

        let normalized: String
        switch (hasComma, hasDot) {
        case (true, true):
            normalized = s.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: ",", with: ".")
        case (true, false):
            normalized = s.replacingOccurrences(of: ",", with: ".")
        case (false, true):
            if matches(thousandsID, s) {
                normalized = s.replacingOccurrences(of: ".", with: "")
            } else {
                normalized = s
            }
        default:
            normalized = s
        }

        return Double(normalized)
    }

}

// MARK: - Single Bar
private struct AllocationBarView: View {
    let title: String
    let percent: Double
    let barWidth: CGFloat
    let maxHeight: CGFloat
    let topColor: Color
    let fillColor: Color
    private let corner: CGFloat = 12

    var body: some View {
        let p = min(max(percent, 0), 1)
        let barHeight = maxHeight * p

        let displayPercent: String = {
            if Int(round(p * 100)) == 0 && p > 0 { return "0.01%" }
            return "\(Int(round(p * 100)))%"
        }()

        ZStack(alignment: .bottom) {
            // BACK: container light brown
            RoundedRectangle(cornerRadius: corner)
                .fill(topColor)

            // FILL: gunakan Rectangle (bukan RoundedRectangle) + align bottom
            Rectangle()
                .fill(fillColor)
                .frame(height: barHeight)

            // LABEL
            VStack(spacing: 4) {
                Text(displayPercent)
                    .font(.system(size: 22, weight: .bold))
                Text(title)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(barHeight > 56 ? Color.backgroundApp : Color.primaryApp)
            .padding(.bottom, barHeight > 56 ? 8 : (barHeight + 8))
        }
        .frame(width: barWidth, height: maxHeight)
        // 🔑 MASK di PALING LUAR → semua isi dipotong sesuai rounded container
        .mask(RoundedRectangle(cornerRadius: corner))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title) \(displayPercent)")
    }
}

// MARK: - Preview (dummy data)

struct AssetAllocationAllChart_Previews: PreviewProvider {
    static var previews: some View {
        let demo = PortfolioOverview(
            portfolioValue: "Rp 100.000.000",
            portfolioGrowthRate: "12.3%",
            portfolioProfitAmount: "Rp 6.500.000",
            groupItems: [
                AssetGroup(name: "Retirement", value: nil, assets: [
                    AssetItem(holding: nil, name: "Bonds",  value: "12", growthRate: nil, profitAmount: nil, quantity: nil),
                    AssetItem(holding: nil, name: "Crypto", value: "20", growthRate: nil, profitAmount: nil, quantity: nil),
                ]),
                AssetGroup(name: "Having Fun", value: nil, assets: [
                    AssetItem(holding: nil, name: "Stocks", value: "30", growthRate: nil, profitAmount: nil, quantity: nil),
                ]),
                AssetGroup(name: "House", value: nil, assets: [
                    AssetItem(holding: nil, name: "Crypto", value: "40", growthRate: nil, profitAmount: nil, quantity: nil),
                    AssetItem(holding: nil, name: "Bonds",  value: "0",  growthRate: nil, profitAmount: nil, quantity: nil),
                ])
            ]
        )

        AssetAllocationAllChart(overview: demo, topN: nil)
            .padding()
            .background(Color.white)
            .previewLayout(.sizeThatFits)
    }
}
