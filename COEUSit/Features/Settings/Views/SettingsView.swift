//
//  SettingsView.swift
//  COEUSit
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        NavigationStack {
            List {
                Section("Profile") {
                    if let profile = authManager.userProfile {
                        HStack(spacing: 16) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.blue)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(profile.name)
                                    .font(.headline)
                                Text(profile.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(profile.role.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .clipShape(Capsule())
                                    .padding(.top, 4)
                            }
                        }
                        .padding(.vertical, 8)
                    } else if let error = authManager.profileError {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Failed to load profile")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: {
                                Task {
                                    await authManager.fetchUserProfile()
                                }
                            }) {
                                Label("Retry", systemImage: "arrow.clockwise")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                        }
                        .padding(.vertical, 8)
                    } else {
                        HStack {
                            ProgressView()
                            Text("Loading profile...")
                                .foregroundColor(.secondary)
                                .padding(.leading, 8)
                        }
                    }
                }

                Button(role: .destructive) {
                    authManager.logout()
                } label: {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                }
            }
        }
        .navigationTitle("Settings")
        .task {
            if authManager.userProfile == nil {
                await authManager.fetchUserProfile()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
