import SwiftUI
import Charts

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

struct InvestmentChart: View {
    let projection: [DataPoint]
    let actual: [DataPoint]

    var lastActual: DataPoint? { actual.last }
    var lastProjection: DataPoint? { projection.last }

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
                    .foregroundStyle(.purple)
                    .lineStyle(.init(lineWidth: 2))
                }

                if let last = lastActual {
                    PointMark(
                        x: .value("Date", last.date),
                        y: .value("Value", last.value)
                    )
                    .symbol(.circle)
                    .foregroundStyle(Color(red: 0.83, green: 0.25, blue: 0.85))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                
                ForEach(projection) { p in
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
                                Color(red: 0.83, green: 0.25, blue: 0.85).opacity(0.6),
                                Color(red: 0.98, green: 0.98, blue: 0.96).opacity(0)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartPlotStyle { $0.background(.clear) }
            .frame(height: 184)
            .padding(.horizontal, 4)
        }
    }
}

func createSampleData() -> (projection: [DataPoint], actual: [DataPoint]) {
    let calendar = Calendar.current
    let startDate = calendar.date(byAdding: .year, value: -2, to: Date())!
    let endDate = calendar.date(byAdding: .year, value: 3, to: Date())!
    
    // Data proyeksi berdasarkan Sharpe Ratio rule
    // Contoh: target return 12% per tahun dengan starting capital 100M
    var projectionData: [DataPoint] = []
    let monthlyReturn = 0.01 // 1% per bulan (12% per tahun)
    var projectedValue = 100_000_000.0 // Starting capital 100 juta
    
    var currentDate = startDate
    while currentDate <= endDate {
        projectionData.append(DataPoint(date: currentDate, value: projectedValue))
        projectedValue *= (1 + monthlyReturn)
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
    }
    
    // Data aktual portfolio (dari awal invest sampai sekarang)
    var actualData: [DataPoint] = []
    var actualValue = 100_000_000.0 // Starting capital yang sama
    
    currentDate = startDate
    let today = Date()
    
    while currentDate <= today {
        // Simulasi fluktuasi pasar yang realistis
        let randomFactor = Double.random(in: -0.08...0.15) // -8% to +15% monthly variation
        actualValue *= (1 + randomFactor)
        actualData.append(DataPoint(date: currentDate, value: actualValue))
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
    }
    
    return (projection: projectionData, actual: actualData)
}


#Preview("Projection vs Actual") {
    let sampleData = createSampleData()
    return InvestmentChart(projection: sampleData.projection,
                           actual: sampleData.actual)
}
