//
//  StatCard.swift
//  COEUSit
//

import SwiftUI

struct StatCard: View {
    enum CardSize {
        case small, medium, large
    }
    
    let title: String
    let value: String
    let icon: String
    let color: Color
    var size: CardSize = .medium
    
    private var iconSize: CGFloat {
        switch size {
        case .small: return 12
        case .medium: return 14
        case .large: return 18
        }
    }
    
    private var titleFont: Font {
        switch size {
        case .small: return .caption2
        case .medium: return .caption
        case .large: return .body
        }
    }
    
    private var valueFont: Font {
        switch size {
        case .small: return .subheadline
        case .medium: return .headline
        case .large: return .title2
        }
    }
    
    private var spacing: CGFloat {
        switch size {
        case .small: return 4
        case .medium: return 8
        case .large: return 12
        }
    }
    
    private var paddingValue: CGFloat {
        switch size {
        case .small: return 10
        case .medium: return 16
        case .large: return 20
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: size == .small ? 4 : 6) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: iconSize))
                Text(title)
                    .font(titleFont)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Text(value)
                .font(valueFont)
                .bold()
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(paddingValue)
        .background(Color.secondarySystemGroupedBackground)
        .cornerRadius(size == .small ? 10 : 12)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            StatCard(title: "Total Devices (Small)", value: "59", icon: "cpu", color: .blue, size: .small)
            StatCard(title: "Total Devices (Medium)", value: "59", icon: "cpu", color: .blue, size: .medium)
            StatCard(title: "Total Devices (Large)", value: "59", icon: "cpu", color: .blue, size: .large)
        }
        .padding()
    }
    .background(Color.systemGroupedBackground)
}
