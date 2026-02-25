//
//  HomeView.swift
//  COEUSit
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Status") {
                    HStack {
                        Label("Temperature", systemImage: "thermometer.medium")
                        Spacer()
                        Text("24°C").bold()
                    }
                    HStack {
                        Label("Humidity", systemImage: "humidity.fill")
                        Spacer()
                        Text("55%").bold()
                    }
                }
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    HomeView()
}
