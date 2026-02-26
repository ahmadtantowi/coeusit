//
//  BatteryView.swift
//  COEUSit
//

import SwiftUI

struct BatteryView: View {
    let percent: Int
    var charging: Bool = false
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: batteryIcon)
            Text("\(percent)%")
        }
        .font(.caption)
        .foregroundColor(batteryColor)
        
        if charging {
            HStack(spacing: 4) {
                Image(systemName: "bolt.fill")
                Text("Charging")
            }
            .font(.caption)
            .foregroundColor(.orange)
        }
    }
    
    private var batteryIcon: String {
        if percent > 80 { return "battery.100" }
        if percent > 50 { return "battery.75" }
        if percent > 20 { return "battery.50" }
        return "battery.25"
    }
    
    private var batteryColor: Color {
        if percent > 20 { return .secondary }
        return .red
    }
}

#Preview {
    VStack(spacing: 10) {
        BatteryView(percent: 90)
        BatteryView(percent: 60)
        BatteryView(percent: 30)
        BatteryView(percent: 10)
    }
}
