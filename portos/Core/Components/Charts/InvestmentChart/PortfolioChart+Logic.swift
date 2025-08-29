//
//  PortfolioChart+Logic.swift
//  portos
//
//  Created by Niki Hidayati on 22/08/25.
//

import SwiftUI
import Charts

enum RangeOption: CaseIterable, Hashable {
    case m3, y1, y5, ytd

    var label: String {
        switch self {
        case .m3:  return "3M"
        case .y1:  return "1Y"
        case .y5:  return "5Y"
        case .ytd: return "ytd".localized
        }
    }

    func startDate(from lastActual: Date) -> Date {
        let cal = Calendar.current
        switch self {
        case .m3:
            return cal.date(byAdding: .month, value: -3, to: lastActual) ?? lastActual
        case .y1:
            return cal.date(byAdding: .year, value: -1, to: lastActual) ?? lastActual
        case .y5:
            return cal.date(byAdding: .year, value: -5, to: lastActual) ?? lastActual
        case .ytd:
            let comps = cal.dateComponents([.year], from: lastActual)
            return cal.date(from: DateComponents(year: comps.year, month: 1, day: 1)) ?? lastActual
        }
    }
}

struct InvestmentChartWithRange: View {
    let projection: [DataPoint]?
    let actual: [DataPoint]
    
    @State private var range: RangeOption = .y1

    private var lastActualDate: Date? { actual.last?.date }
    private var startDate: Date {
        guard let last = lastActualDate else { return .now }
        return range.startDate(from: last)
    }

    private var endDate: Date {
        let lastActual = actual.last?.date ?? .now
        if projection != nil {
            let lastProj   = projection?.last?.date ?? lastActual
            return max(lastActual, lastProj)
        } else {
            return lastActual
        }
    }

    private var actualFiltered: [DataPoint] {
        guard let last = lastActualDate else { return [] }
        return actual.filter { $0.date >= startDate && $0.date <= last }
    }

    private var projectionFiltered: [DataPoint] {
        projection?.filter { $0.date >= startDate && $0.date <= endDate } ?? []
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

func sumSeries(_ seriesList: [[DataPoint]]) -> [DataPoint] {
    var sumByDate: [Date: Double] = [:]
    let cal = Calendar.current

    for series in seriesList {
        for p in series {
            let key = startOfMonth(p.date, cal)   // tanggal diseragamkan ke awal bulan
            sumByDate[key, default: 0] += p.value
        }
    }

    // Balik jadi array urut tanggal naik
    return sumByDate
        .map { DataPoint(date: $0.key, value: $0.value) }
        .sorted { $0.date < $1.date }
}

private func startOfMonth(_ date: Date, _ cal: Calendar = .current) -> Date {
    let comp = cal.dateComponents([.year, .month], from: date)
    return cal.date(from: comp) ?? date
}
