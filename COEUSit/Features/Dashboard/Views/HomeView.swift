//
//  HomeView.swift
//  COEUSit
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    VStack(alignment: .leading, spacing: 20) {
                        dashboardGrid(viewModel.dashboardData)
                    }
                    .padding()
                    .opacity(viewModel.isLoading ? 0.6 : 1.0)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .padding()
                            .background(Color.systemBackground.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
            }
            .background(Color.systemGroupedBackground)
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.fetchDashboardData(token: authManager.token)
            }
            .alert("Failed to Load Dashboard", isPresented: $viewModel.showErrorAlert) {
                Button("Refresh") {
                    Task {
                        await viewModel.fetchDashboardData(token: authManager.token)
                    }
                }
                Button("Dismiss", role: .cancel) { }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                } else {
                    Text("Something went wrong.")
                }
            }
            .task {
                await viewModel.fetchDashboardData(token: authManager.token)
            }
        }
    }
    
    private func dashboardGrid(_ data: DashboardData) -> some View {
        LazyVGrid(columns: columns, spacing: 16) {
            StatCard(
                title: "Total Devices",
                value: "\(data.totalCount)",
                icon: "cpu",
                color: .blue,
                size: .large
            )
            
            StatCard(
                title: "Unconfigured",
                value: "\(data.unconfiguredCount)",
                icon: "display.trianglebadge.exclamationmark",
                color: .purple,
                size: .large
            )
            
            StatCard(
                title: "Online",
                value: "\(data.onlineCount)",
                icon: "wifi",
                color: .green,
                size: .large
            )
            
            StatCard(
                title: "Offline",
                value: "\(data.offlineCount)",
                icon: "wifi.slash",
                color: .gray,
                size: .large
            )
            
            StatCard(
                title: "Alarms",
                value: "\(data.alarmCount)",
                icon: "light.beacon.max.fill",
                color: .red,
                size: .large
            )
            
            StatCard(
                title: "Low Battery",
                value: "\(data.lowBatteryCount)",
                icon: "battery.25",
                color: .orange,
                size: .large
            )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
