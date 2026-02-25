//
//  DevicesView.swift
//  COEUSit
//

import SwiftUI

struct DevicesView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView("No Devices", systemImage: "sensor.fill", description: Text("You haven't added any sensors yet."))
                .navigationTitle("Devices")
                .toolbar {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
        }
    }
}

#Preview {
    DevicesView()
}
