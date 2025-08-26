//
//  PortfolioChart+Logic.swift
//  portos
//
//  Created by Niki Hidayati on 22/08/25.
//

import SwiftUI
import Charts

enum RangeOption: CaseIterable, Hashable {
    case oneY, threeY, sixY, nineY, twelveY, ytd

    var label: String {
        switch self {
        case .oneY: return "1Y"
        case .threeY: return "3Y"
        case .sixY: return "6Y"
        case .nineY: return "9Y"
        case .twelveY: return "12Y"
        case .ytd: return "YTD"
        }
    }

    func startDate(from lastActual: Date) -> Date {
        let cal = Calendar.current
        switch self {
        case .oneY:     return cal.date(byAdding: .year, value: -1, to: lastActual) ?? lastActual
        case .threeY:   return cal.date(byAdding: .year, value: -3, to: lastActual) ?? lastActual
        case .sixY:     return cal.date(byAdding: .year, value: -6, to: lastActual) ?? lastActual
        case .nineY:    return cal.date(byAdding: .year, value: -9, to: lastActual) ?? lastActual
        case .twelveY:  return cal.date(byAdding: .year, value: -12, to: lastActual) ?? lastActual
        case .ytd:
            let comps = cal.dateComponents([.year], from: lastActual)
            return cal.date(from: DateComponents(year: comps.year, month: 1, day: 1)) ?? lastActual
        }
    }
}

struct InvestmentChartWithRange: View {
    let projection: [DataPoint]
    let actual: [DataPoint]

    @State private var range: RangeOption = .sixY

    private var lastActualDate: Date? { actual.last?.date }
    private var startDate: Date {
        guard let last = lastActualDate else { return .now }
        return range.startDate(from: last)
    }

    private var endDate: Date {
        let lastActual = actual.last?.date ?? .now
        let lastProj   = projection.last?.date ?? lastActual
        return max(lastActual, lastProj)
    }

    private var actualFiltered: [DataPoint] {
        guard let last = lastActualDate else { return [] }
        return actual.filter { $0.date >= startDate && $0.date <= last }
    }

    private var projectionFiltered: [DataPoint] {
        projection.filter { $0.date >= startDate && $0.date <= endDate }
    }



    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            InvestmentChart(
                projection: projectionFiltered,
                actual: actualFiltered
            )
            .chartXScale(domain: startDate...endDate)
            
            RangeTabs(selection: $range)
        }
        .padding(.horizontal)
    }
}

struct RangeTabs: View {
    @Binding var selection: RangeOption

    var body: some View {
        HStack(spacing: 24) {
            ForEach(RangeOption.allCases, id: \.self) { opt in
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) { selection = opt }
                } label: {
                    Text(opt.label)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(selection == opt ? .black : Color(red: 0.7, green: 0.7, blue: 0.7))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 4)
    }
}
