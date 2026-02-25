//
//  SearchView.swift
//  COEUSit
//

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            List {
                Text("Recent Searches")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Search")
            .searchable(text: $searchText)
        }
    }
}

#Preview {
    SearchView()
}
