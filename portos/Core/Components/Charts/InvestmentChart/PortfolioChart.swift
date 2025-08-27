import SwiftUI
import Charts

struct InvestmentChart: View {
    let projection: [DataPoint]?
    let actual: [DataPoint]

    var lastActual: DataPoint? { actual.last }
    var lastProjection: DataPoint? { projection?.last }

    var body: some View {
        VStack {
            Chart {
                ForEach(actual) { p in
                    LineMark(
                        x: .value("Date", p.date),
                        y: .value("Value", p.value),
                        series: .value("Type", "Actual")
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(Color.greenApp)
                    .lineStyle(.init(lineWidth: 2))
                }

                if let last = lastActual {
                    PointMark(
                        x: .value("Date", last.date),
                        y: .value("Value", last.value)
                    )
                    .symbol(.circle)
                    .foregroundStyle(Color.greenApp)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                
                ForEach(projection ?? []) { p in
                    LineMark(
                        x: .value("Date", p.date),
                        y: .value("Value", p.value),
                        series: .value("Type", "Projection")
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [6,6]))
                }
                
                if let last = lastProjection {
                    PointMark(
                        x: .value("Date", last.date),
                        y: .value("Value", last.value)
                    )
                    .symbol(.circle)
                    .foregroundStyle(.gray)
                }

                ForEach(actual) { p in
                    AreaMark(
                        x: .value("Date", p.date),
                        y: .value("Value", p.value)
                    )
                    .interpolationMethod(.monotone)
                    .foregroundStyle(
                        .linearGradient(
                            colors: [
                                Color.greenApp.opacity(0.51),
                                Color.backgroundApp],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { $0.background(.clear) }
            .frame(height: 184)
        }
    }
}

struct EmptyInvestmentChart: View {
    private var placeholder: [DataPoint] {
        let start = Calendar.current.date(byAdding: .year, value: -5, to: Date()) ?? Date()
        let end   = Date()
        return [
            DataPoint(date: start, value: 0),
            DataPoint(date: end,   value: 1)
        ]
    }

    var body: some View {
        Chart {
            ForEach(placeholder) { p in
                LineMark(
                    x: .value("Date", p.date),
                    y: .value("Value", p.value)
                )
                .interpolationMethod(.linear)
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6]))
                .foregroundStyle(Color.greyApp)
            }

            if let first = placeholder.first {
                PointMark(
                    x: .value("Date", first.date),
                    y: .value("Value", first.value)
                )
                .foregroundStyle(Color.greyApp)
                .symbolSize(80)
            }

            if let last = placeholder.last {
                PointMark(
                    x: .value("Date", last.date),
                    y: .value("Value", last.value)
                )
                .foregroundStyle(Color.greyApp)
                .symbolSize(80)
            }
        }
        .padding(.horizontal, 6)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartPlotStyle { $0.background(.clear) }
        .frame(height: 184)
    }
}

#Preview() {
    EmptyInvestmentChart()
}

//#Preview() {
//    let march  = Calendar.current.date(from: DateComponents(year: 2025, month: 3, day: 1))!
//    let april  = Calendar.current.date(from: DateComponents(year: 2025, month: 4, day: 1))!
//    let may =  Calendar.current.date(from: DateComponents(year: 2025, month: 5, day: 1))!
//    let june = Calendar.current.date(from: DateComponents(year: 2025, month: 6, day: 1))!
//
//    let actual = [
//        DataPoint(date: march, value: 3000000000),
//        DataPoint(date: april, value: 3000000000),
//        DataPoint(date: may, value: 3999900000),
//        DataPoint(date: june, value: 3001000000),
//    ]
//    return InvestmentChart(projection: actual,
//                           actual: actual)
//}
