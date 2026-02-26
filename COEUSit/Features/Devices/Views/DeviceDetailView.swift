//
//  DeviceDetailView.swift
//  COEUSit
//

import SwiftUI

struct DeviceDetailView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: DeviceSummaryViewModel
    @State private var showingFilters = false
    
    // Temporary state for the date picker sheet
    @State private var tempStartDate: Date = Date()
    @State private var tempEndDate: Date = Date()
    
    init(deviceId: String) {
        _viewModel = StateObject(wrappedValue: DeviceSummaryViewModel(deviceId: deviceId))
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all)
            
            if let summary = viewModel.summary {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Device Header
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(summary.device.serialNumber)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                Text(summary.device.online ? "Online" : "Offline")
                                    .font(.system(size: 10, weight: .bold))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(summary.device.online ? Color.green.opacity(0.15) : Color.red.opacity(0.15))
                                    .foregroundColor(summary.device.online ? .green : .red)
                                    .clipShape(Capsule())
                                
                                Spacer()
                            }
                            
                            Text(summary.device.name ?? "Unnamed Device")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                BatteryView(percent: summary.device.batteryPercent, charging: summary.device.charging)
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "globe")
                                    Text(summary.device.timezone)
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // Summary Stats
                        if let stats = summary.stats {
                            statsSection(stats)
                        }
                        
                        // Charts
                        if let records = summary.records, !records.isEmpty {
                            TemperatureChartView(records: records, tempUnit: tempUnitSymbol)
                                .padding(.horizontal)
                            
                            HumidityChartView(records: records)
                                .padding(.horizontal)
                        }
                        
                        // Records
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Records")
                                    .font(.headline)
                                
                                if let type = viewModel.selectedProbeType {
                                    Text("(\(type))")
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(.horizontal)
                            
                            let records = summary.records ?? []
                            
                            if records.isEmpty {
                                Text("No records available for the selected criteria.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(records) { record in
                                        recordRow(record)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .refreshable {
                    await viewModel.fetchSummary(accessToken: authManager.token)
                }
            } else if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.error {
                errorView(error)
            } else {
                // If we reach here, it means summary is nil and not loading and no error.
                // This could happen if fetch hasn't started yet.
                loadingView
            }
        }
        .navigationTitle("Device Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isLoading && viewModel.summary != nil {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                filterMenu
            }
        }
        .sheet(isPresented: $showingFilters) {
            dateRangePickerSheet
        }
        .task {
            // Initial fetch
            if viewModel.summary == nil {
                await viewModel.fetchSummary(accessToken: authManager.token)
            }
        }
        .onChange(of: viewModel.selectedProbeType) {
            Task { await viewModel.fetchSummary(accessToken: authManager.token) }
        }
    }
    
    private var loadingView: some View {
        VStack {
            ProgressView()
            Text("Loading device details...")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func errorView(_ error: Error) -> some View {
        ContentUnavailableView(
            "Error",
            systemImage: "exclamationmark.triangle",
            description: Text(error.localizedDescription)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var filterMenu: some View {
        Menu {
            Button {
                tempStartDate = viewModel.startDate
                tempEndDate = viewModel.endDate
                showingFilters = true
            } label: {
                Label("Date Range", systemImage: "calendar")
            }
            
            Menu {
                Button {
                    viewModel.selectedProbeType = nil
                } label: {
                    HStack {
                        Text("All Probes")
                        if viewModel.selectedProbeType == nil { Image(systemName: "checkmark") }
                    }
                }
                
                probeTypeButton(label: "Built-in", value: "Built-in")
                probeTypeButton(label: "External 1", value: "External1")
                probeTypeButton(label: "External 2", value: "External2")
            } label: {
                Label("Probe Type", systemImage: "sensor")
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .symbolVariant((viewModel.selectedProbeType != nil) ? .fill : .none)
        }
    }
    
    private func probeTypeButton(label: String, value: String) -> some View {
        Button {
            viewModel.selectedProbeType = value
        } label: {
            HStack {
                Text(label)
                if viewModel.selectedProbeType == value { Image(systemName: "checkmark") }
            }
        }
    }
    
    private var dateRangePickerSheet: some View {
        NavigationStack {
            Form {
                Section("Select Range") {
                    DatePicker("Start Date", selection: $tempStartDate)
                    DatePicker("End Date", selection: $tempEndDate)
                }
                
                Section {
                    Button("Quick Range: Last 24h") {
                        let end = Date()
                        tempEndDate = end
                        tempStartDate = Calendar.current.date(byAdding: .day, value: -1, to: end) ?? end
                    }
                    Button("Quick Range: Last 7 Days") {
                        let end = Date()
                        tempEndDate = end
                        tempStartDate = Calendar.current.date(byAdding: .day, value: -7, to: end) ?? end
                    }
                }
            }
            .navigationTitle("Date Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        showingFilters = false
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.startDate = tempStartDate
                        viewModel.endDate = tempEndDate
                        showingFilters = false
                        Task {
                            await viewModel.fetchSummary(accessToken: authManager.token)
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var tempUnitSymbol: String {
        viewModel.summary?.device.temperatureUnit == "Fahrenheit" ? "°F" : "°C"
    }
    
    private func statsSection(_ stats: SummaryStats) -> some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                statCard(title: "Avg Temp", value: stats.avgTemp.map { String(format: "%.1f%@", $0, tempUnitSymbol) } ?? "--\(tempUnitSymbol)", icon: "thermometer.medium", color: .orange)
                statCard(title: "Avg Humidity", value: stats.avgHumidity.map { String(format: "%.1f%%", $0) } ?? "--%", icon: "drop.fill", color: .blue.opacity(0.6))
            }
            
            HStack(spacing: 16) {
                statCard(title: "Min", value: stats.min?.temperature.map { String(format: "%.1f%", $0) } ?? "--", icon: "thermometer.medium", color: .blue)
                statCard(title: "Max", value: stats.max?.temperature.map { String(format: "%.1f%", $0) } ?? "--", icon: "thermometer.medium", color: .red)
                
                statCard(title: "Min", value: stats.min?.humidity.map { String(format: "%.1f%", $0) } ?? "--", icon: "drop.fill", color: .blue.opacity(0.2))
                statCard(title: "Max", value: stats.max?.humidity.map{ String(format: "%.1f%", $0) } ?? "--", icon: "drop.fill", color: .blue)
            }
        }
        .padding(.horizontal)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func recordRow(_ record: DeviceRecord) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formatDate(record.time ?? ""))
                    .font(.system(size: 14, weight: .medium))
                
                HStack(spacing: 6) {
                    Text(record.probeType ?? "Unknown")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.secondary)
                        .cornerRadius(4)
                    
                    if let status = record.status, !status.isEmpty {
                        Text(status.capitalized)
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(statusColor(status).opacity(0.15))
                            .foregroundColor(statusColor(status))
                            .cornerRadius(4)
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(record.temperature.map { String(format: "%.1f%@", $0, tempUnitSymbol) } ?? "--\(tempUnitSymbol)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("Temp")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(record.humidity.map { String(format: "%.1f%%", $0) } ?? "--%")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Text("Humidity")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: dateString) else { return dateString }
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "MMM d, HH:mm"
        return displayFormatter.string(from: date)
    }
    
    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "sync": return .green
        case "queue": return .orange
        case "skip": return .gray
        default: return .blue
        }
    }
}
