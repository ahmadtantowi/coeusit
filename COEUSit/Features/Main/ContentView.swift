//
//  ContentView.swift
//  COEUSit
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        if authManager.isLoggedIn {
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                DevicesView()
                    .tabItem {
                        Label("Devices", systemImage: "sensor.fill")
                    }
                
                GroupsView()
                    .tabItem {
                        Label("Groups", systemImage: "rectangle.3.group.fill")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                    }
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
