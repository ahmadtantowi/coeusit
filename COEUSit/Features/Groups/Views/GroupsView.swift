//
//  GroupsView.swift
//  COEUSit
//

import SwiftUI
import MapKit

struct GroupsView: View {
    @StateObject private var viewModel = GroupsViewModel()
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.groups.isEmpty {
                    ProgressView()
                } else if let error = viewModel.error {
                    VStack {
                        Text("Error: \(error.localizedDescription)")
                            .foregroundColor(.red)
                        Button("Retry") {
                            Task {
                                await viewModel.fetchGroups(accessToken: authManager.token)
                            }
                        }
                        .padding()
                    }
                } else if viewModel.filteredGroups.isEmpty {
                    ContentUnavailableView(
                        viewModel.searchText.isEmpty && viewModel.selectedSyncFilter == nil ? "No Groups" : "No Results",
                        systemImage: viewModel.searchText.isEmpty && viewModel.selectedSyncFilter == nil ? "folder" : "magnifyingglass",
                        description: Text(viewModel.searchText.isEmpty && viewModel.selectedSyncFilter == nil ? "You haven't created any groups yet." : "No groups match your search or filter criteria.")
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredGroups) { group in
                                NavigationLink(destination: DevicesView(groupId: group.id, groupName: group.name)
                                    .toolbar(.hidden, for: .tabBar)) {
                                    GroupCard(group: group)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    .background(Color(UIColor.systemGroupedBackground))
                    .refreshable {
                        await viewModel.fetchGroups(accessToken: authManager.token)
                    }
                }
            }
            .navigationTitle("Groups")
            .searchable(text: $viewModel.searchText, prompt: "Search group name")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    filterMenu
                }
            }
            .onAppear {
                if viewModel.groups.isEmpty {
                    Task {
                        await viewModel.fetchGroups(accessToken: authManager.token)
                    }
                }
            }
        }
    }

    private var filterMenu: some View {
        Menu {
            Section("Sync to SMILE") {
                Button {
                    viewModel.selectedSyncFilter = nil
                } label: {
                    HStack {
                        Text("All")
                        if viewModel.selectedSyncFilter == nil { Image(systemName: "checkmark") }
                    }
                }
                
                Button {
                    viewModel.selectedSyncFilter = true
                } label: {
                    HStack {
                        Text("Enabled")
                        if viewModel.selectedSyncFilter == true { Image(systemName: "checkmark") }
                    }
                }
                
                Button {
                    viewModel.selectedSyncFilter = false
                } label: {
                    HStack {
                        Text("Disabled")
                        if viewModel.selectedSyncFilter == false { Image(systemName: "checkmark") }
                    }
                }
            }
        } label: {
            Image(systemName: viewModel.selectedSyncFilter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                .foregroundColor(viewModel.selectedSyncFilter == nil ? .primary : .accentColor)
        }
    }
}

struct GroupCard: View {
    let group: GroupModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Details Column
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                    .lineLimit(2)
                
                if let description = group.description, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: group.syncToSmile ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(group.syncToSmile ? .green : .red)
                        .font(.caption)
                    Text("Sync to SMILE")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            // Map Column
            if let lat = group.locationLatitude, let lon = group.locationLongitude {
                Map(initialPosition: .region(MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                ))) {
                    Marker("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                }
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .disabled(true)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let ISO8601Formatter = ISO8601DateFormatter()
        ISO8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = ISO8601Formatter.date(from: dateString) {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    GroupsView()
        .environmentObject(AuthManager())
}
