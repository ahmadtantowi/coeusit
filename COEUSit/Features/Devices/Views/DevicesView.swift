//
//  DevicesView.swift
//  COEUSit
//

import SwiftUI

struct DevicesView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = DevicesViewModel()
    @State private var searchTask: Task<Void, Never>? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.devices.isEmpty && viewModel.isLoading {
                    ProgressView("Loading devices...")
                } else if viewModel.devices.isEmpty && !viewModel.isLoading {
                    ContentUnavailableView(
                        viewModel.searchText.isEmpty && viewModel.selectedStatus == nil ? "No Devices" : "No Results",
                        systemImage: viewModel.searchText.isEmpty && viewModel.selectedStatus == nil ? "sensor.fill" : "magnifyingglass",
                        description: Text(viewModel.searchText.isEmpty && viewModel.selectedStatus == nil ? "You haven't added any sensors yet." : "No devices match your search or filter criteria.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.devices) { device in
                                DeviceRow(device: device)
                                    .onAppear {
                                        if device.id == viewModel.devices.last?.id {
                                            Task {
                                                await viewModel.fetchNextPage(accessToken: authManager.token)
                                            }
                                        }
                                    }
                            }
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .padding(.vertical)
                            }
                        }
                        .padding()
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    .refreshable {
                        await viewModel.fetchInitialDevices(accessToken: authManager.token)
                    }
                }
            }
            .navigationTitle("Devices")
            .searchable(text: $viewModel.searchText, placement: .toolbar, prompt: "Search serial number or name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
            }
            .task {
                if viewModel.devices.isEmpty {
                    await viewModel.fetchInitialDevices(accessToken: authManager.token)
                }
            }
            // Trigger API call when search text changes (with manual debounce)
            .onChange(of: viewModel.searchText) { _, newValue in
                searchTask?.cancel()
                searchTask = Task {
                    // 500ms debounce
                    try? await Task.sleep(nanoseconds: 500_000_000)
                    if !Task.isCancelled {
                        await viewModel.fetchInitialDevices(accessToken: authManager.token)
                    }
                }
            }
            // Trigger API call when status selection changes
            .onChange(of: viewModel.selectedStatus) {
                Task {
                    await viewModel.fetchInitialDevices(accessToken: authManager.token)
                }
            }
            .alert("Error", isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    private var filterMenu: some View {
        Menu {
            Section("Status") {
                Button {
                    viewModel.selectedStatus = nil
                } label: {
                    HStack {
                        Text("All")
                        if viewModel.selectedStatus == nil { Image(systemName: "checkmark") }
                    }
                }
                
                statusButton(label: "Online", value: "online")
                statusButton(label: "Offline", value: "offline")
                statusButton(label: "No Record", value: "no_record")
                statusButton(label: "Probe Error", value: "probe_error")
            }
        } label: {
            Image(systemName: viewModel.selectedStatus == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(viewModel.selectedStatus == nil ? .primary : .accentColor)
        }
    }
    
    private func statusButton(label: String, value: String) -> some View {
        Button {
            viewModel.selectedStatus = value
        } label: {
            HStack {
                Text(label)
                if viewModel.selectedStatus == value { Image(systemName: "checkmark") }
            }
        }
    }
}

struct DeviceRow: View {
    let device: Device
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .center, spacing: 4) {
                HStack(spacing: 2) {
                    Image(systemName: "thermometer.medium")
                        .font(.system(size: 14))
                    if let temp = device.lastTemperature {
                        Text(String(format: "%.1f°", temp))
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    } else {
                        Text("--°")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(statusColor)
                
                HStack(spacing: 2) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 10))
                    if let humidity = device.lastHumidity {
                        Text(String(format: "%.0f%%", humidity))
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    } else {
                        Text("--%")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                    }
                }
                .foregroundColor(.blue)
            }
            .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(device.serialNumber)
                        .font(.headline)
                    
                    if (!device.configured) {
                        Image(systemName: "moonphase.new.moon.inverse")
                            .font(.system(size: 10))
                            .foregroundStyle(.green)
                    }
                    
                    Image(systemName: (device.smileSerialNumber != nil) ? "cloud.fill" : "cloud")
                        .font(.system(size: 12))
                        .foregroundStyle((device.smileSerialNumber != nil) ? .green : .gray)
                    
                    Spacer()
                    batteryView
                }
                
                HStack {
                    Text(device.name ?? "Unnamed Device")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatStatus(device.status))
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(statusColor.opacity(0.15))
                        .foregroundColor(statusColor)
                        .clipShape(Capsule())
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatStatus(_ status: String) -> String {
        status.replacingOccurrences(of: "_", with: " ").capitalized
    }
    
    private var batteryView: some View {
        HStack(spacing: 4) {
            Image(systemName: batteryIcon)
            Text("\(device.batteryPercent)%")
        }
        .font(.caption)
        .foregroundColor(batteryColor)
    }
    
    private var batteryIcon: String {
        if device.batteryPercent > 80 { return "battery.100" }
        if device.batteryPercent > 50 { return "battery.75" }
        if device.batteryPercent > 20 { return "battery.50" }
        return "battery.25"
    }
    
    private var batteryColor: Color {
        if device.batteryPercent > 20 { return .secondary }
        return .red
    }
    
    private var statusColor: Color {
        switch device.status.lowercased() {
        case "online": return .green
        case "offline": return .red
        case "no_record": return .gray
        case "probe_error": return .purple
        default: return .orange
        }
    }
}

#Preview {
    DevicesView()
        .environmentObject(AuthManager())
}
