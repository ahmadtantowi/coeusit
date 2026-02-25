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
                    Label("Account Settings", systemImage: "person.crop.circle")
                    Label("Notifications", systemImage: "bell.fill")
                }
                
                Section {
                    Button(role: .destructive) {
                        authManager.logout()
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthManager())
}
