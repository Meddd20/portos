import Foundation

// MARK: - Monte Carlo Configuration
struct MonteCarloConfig {
    let numberOfSimulations: Int
    let projectionDays: Int
    let confidenceLevel: Double // 0.95 untuk 95% confidence interval
    
    static let `default` = MonteCarloConfig(
        numberOfSimulations: 1000,
        projectionDays: 30,
        confidenceLevel: 0.95
    )
}

// MARK: - Monte Carlo Helper Class
class MonteCarloProjectionHelper {
    
    // MARK: - Public Methods
    
    /// Menghitung projection series menggunakan Monte Carlo simulation
    /// - Parameters:
    ///   - actualSeries: Array DataPoint dari data historis
    ///   - config: Konfigurasi Monte Carlo (optional, menggunakan default jika nil)
    /// - Returns: Array DataPoint untuk projection series
    static func calculateProjection(
        from actualSeries: [DataPoint],
        config: MonteCarloConfig = .default
    ) -> [DataPoint] {
        
        guard actualSeries.count >= 2 else {
            print("Warning: Butuh minimal 2 data points untuk Monte Carlo simulation")
            return []
        }
        
        // 1. Hitung daily returns dari actual data
        let dailyReturns = calculateDailyReturns(from: actualSeries)
        
        // 2. Hitung statistik dari returns
        let returnStats = calculateReturnStatistics(from: dailyReturns)
        
        // 3. Jalankan Monte Carlo simulation
        let simulations = runMonteCarloSimulations(
            startingValue: actualSeries.last!.value,
            startingDate: actualSeries.last!.date,
            returnStats: returnStats,
            config: config
        )
        
        // 4. Hitung confidence intervals untuk setiap hari
        let projectionSeries = calculateConfidenceIntervals(
            from: simulations,
            startingDate: actualSeries.last!.date,
            config: config
        )
        
        return projectionSeries
    }
    
    // MARK: - Private Helper Methods
    
    /// Menghitung daily returns dari time series data
    private static func calculateDailyReturns(from series: [DataPoint]) -> [Double] {
        var returns: [Double] = []
        
        for i in 1..<series.count {
            let previousValue = series[i-1].value
            let currentValue = series[i].value
            
            if previousValue > 0 {
                let dailyReturn = (currentValue - previousValue) / previousValue
                returns.append(dailyReturn)
            }
        }
        
        return returns
    }
    
    /// Menghitung statistik dari returns (mean dan standard deviation)
    private static func calculateReturnStatistics(from returns: [Double]) -> (mean: Double, stdDev: Double) {
        guard !returns.isEmpty else { return (0, 0) }
        
        // Mean
        let mean = returns.reduce(0, +) / Double(returns.count)
        
        // Standard Deviation
        let variance = returns.reduce(0) { sum, return_ in
            sum + pow(return_ - mean, 2)
        } / Double(returns.count - 1)
        
        let stdDev = sqrt(variance)
        
        return (mean: mean, stdDev: stdDev)
    }
    
    /// Menjalankan Monte Carlo simulations
    private static func runMonteCarloSimulations(
        startingValue: Double,
        startingDate: Date,
        returnStats: (mean: Double, stdDev: Double),
        config: MonteCarloConfig
    ) -> [[Double]] {
        
        var allSimulations: [[Double]] = []
        
        for _ in 0..<config.numberOfSimulations {
            var simulation: [Double] = [startingValue]
            var currentValue = startingValue
            
            for _ in 1...config.projectionDays {
                // Generate random return menggunakan normal distribution
                let randomReturn = generateNormalRandom(
                    mean: returnStats.mean,
                    stdDev: returnStats.stdDev
                )
                
                // Apply return ke current value
                currentValue = currentValue * (1 + randomReturn)
                simulation.append(currentValue)
            }
            
            allSimulations.append(simulation)
        }
        
        return allSimulations
    }
    
    /// Generate random number dengan normal distribution (Box-Muller transform)
    private static func generateNormalRandom(mean: Double, stdDev: Double) -> Double {
        // Box-Muller transform untuk generate normal distribution
        let u1 = Double.random(in: 0..<1)
        let u2 = Double.random(in: 0..<1)
        
        let z0 = sqrt(-2 * log(u1)) * cos(2 * .pi * u2)
        return mean + stdDev * z0
    }
    
    /// Menghitung confidence intervals dari hasil simulations
    private static func calculateConfidenceIntervals(
        from simulations: [[Double]],
        startingDate: Date,
        config: MonteCarloConfig
    ) -> [DataPoint] {
        
        var projectionSeries: [DataPoint] = []
        let calendar = Calendar.current
        
        // Skip index 0 karena itu starting value
        for dayIndex in 1...config.projectionDays {
            // Kumpulkan semua values untuk hari ini dari semua simulations
            let valuesForThisDay = simulations.map { $0[dayIndex] }
            
            // Sort untuk menghitung percentiles
            let sortedValues = valuesForThisDay.sorted()
            
            // Hitung median (50th percentile) sebagai projected value
            let medianIndex = sortedValues.count / 2
            let projectedValue = sortedValues.count % 2 == 0 ?
                (sortedValues[medianIndex - 1] + sortedValues[medianIndex]) / 2.0 :
                sortedValues[medianIndex]
            
            // Hitung tanggal untuk projection point
            let projectionDate = calendar.date(
                byAdding: .day,
                value: dayIndex,
                to: startingDate
            ) ?? startingDate
            
            // Buat DataPoint untuk projection
            let dataPoint = DataPoint(
                date: projectionDate,
                value: projectedValue
            )
            
            projectionSeries.append(dataPoint)
        }
        
        return projectionSeries
    }
    
    // MARK: - Additional Utility Methods
    
    /// Menghitung confidence bands (upper dan lower bounds)
    static func calculateConfidenceBands(
        from actualSeries: [DataPoint],
        config: MonteCarloConfig = .default
    ) -> (upper: [DataPoint], lower: [DataPoint]) {
        
        guard actualSeries.count >= 2 else {
            return ([], [])
        }
        
        let dailyReturns = calculateDailyReturns(from: actualSeries)
        let returnStats = calculateReturnStatistics(from: dailyReturns)
        
        let simulations = runMonteCarloSimulations(
            startingValue: actualSeries.last!.value,
            startingDate: actualSeries.last!.date,
            returnStats: returnStats,
            config: config
        )
        
        var upperBand: [DataPoint] = []
        var lowerBand: [DataPoint] = []
        let calendar = Calendar.current
        
        // Hitung percentiles untuk confidence bands
        let upperPercentile = (1.0 + config.confidenceLevel) / 2.0
        let lowerPercentile = (1.0 - config.confidenceLevel) / 2.0
        
        for dayIndex in 1...config.projectionDays {
            let valuesForThisDay = simulations.map { $0[dayIndex] }
            let sortedValues = valuesForThisDay.sorted()
            
            let upperIndex = Int(Double(sortedValues.count - 1) * upperPercentile)
            let lowerIndex = Int(Double(sortedValues.count - 1) * lowerPercentile)
            
            let projectionDate = calendar.date(
                byAdding: .day,
                value: dayIndex,
                to: actualSeries.last!.date
            ) ?? actualSeries.last!.date
            
            upperBand.append(DataPoint(date: projectionDate, value: sortedValues[upperIndex]))
            lowerBand.append(DataPoint(date: projectionDate, value: sortedValues[lowerIndex]))
        }
        
        return (upper: upperBand, lower: lowerBand)
    }
}
