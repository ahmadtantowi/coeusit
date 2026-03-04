//
//  DeviceChartsView.swift
//  COEUSit
//

import SwiftUI
import Charts

struct TemperatureChartView: View {
    let records: [DeviceRecord]
    let tempUnit: String
    
    private var chartData: [(date: Date, value: Double)] {
        records.compactMap { record in
            guard let date = record.date,
                  let val = record.temperature else { return nil }
            return (date: date, value: val)
        }.sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Temperature (\(tempUnit))")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("No data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(chartData, id: \.date) { data in
                        LineMark(
                            x: .value("Time", data.date),
                            y: .value("Temperature", data.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.orange)
                        
                        AreaMark(
                            x: .value("Time", data.date),
                            y: .value("Temperature", data.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(
                            colors: [.orange.opacity(0.3), .orange.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    }
                    
                    RuleMark(y: .value("Baseline", 0))
                        .foregroundStyle(.gray.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .frame(height: 150)
                .chartYScale(domain: tempScale)
                .chartXAxis {
                    xAxisMarks(for: chartData.map { $0.date })
                }
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(12)
    }
    
    private var tempScale: ClosedRange<Double> {
        let values = chartData.map { $0.value }
        guard let maxVal = values.max() else { return 0...50 }
        let minVal = values.min() ?? 0
        let bottom = min(0, minVal - 5) // If sub-zero, show more below, else start at 0
        let top = maxVal + 5
        return bottom...top
    }
}

struct HumidityChartView: View {
    let records: [DeviceRecord]
    
    private var chartData: [(date: Date, value: Double)] {
        records.compactMap { record in
            guard let date = record.date,
                  let val = record.humidity else { return nil }
            return (date: date, value: val)
        }.sorted(by: { $0.date < $1.date })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Humidity (%)")
                .font(.headline)
            
            if chartData.isEmpty {
                Text("No data available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
            } else {
                Chart {
                    ForEach(chartData, id: \.date) { data in
                        LineMark(
                            x: .value("Time", data.date),
                            y: .value("Humidity", data.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)
                        
                        AreaMark(
                            x: .value("Time", data.date),
                            y: .value("Humidity", data.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(LinearGradient(
                            colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    }
                    
                    RuleMark(y: .value("Baseline", 0))
                        .foregroundStyle(.gray.opacity(0.3))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                }
                .frame(height: 150)
                .chartYScale(domain: 0...100)
                .chartXAxis {
                    xAxisMarks(for: chartData.map { $0.date })
                }
            }
        }
        .padding()
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(12)
    }
}

// Helper to avoid duplication in same file
@available(iOS 16.0, *)
func xAxisMarks(for dates: [Date]) -> some AxisContent {
    guard let first = dates.first, let last = dates.last else {
        return AxisMarks() { _ in 
            AxisGridLine()
            AxisTick()
            AxisValueLabel()
        }
    }
    
    let duration = last.timeIntervalSince(first)
    
    if duration > 48 * 3600 { // More than 2 days
        return AxisMarks(values: .stride(by: .day)) { value in
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .dateTime.day().month())
        }
    } else if duration > 12 * 3600 { // More than 12 hours
        return AxisMarks(values: .stride(by: .hour, count: 6)) { value in
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
        }
    } else {
        return AxisMarks(values: .stride(by: .hour, count: 1)) { value in
            AxisGridLine()
            AxisTick()
            AxisValueLabel(format: .dateTime.hour(.twoDigits(amPM: .omitted)))
        }
    }
}
