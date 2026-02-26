//
//  GroupsViewModel.swift
//  COEUSit
//

import Foundation
import SwiftUI
import Combine

@MainActor
class GroupsViewModel: ObservableObject {
    @Published var groups: [GroupModel] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var searchText: String = ""
    @Published var selectedSyncFilter: Bool? = nil
    
    private let groupService = GroupService()
    private var fetchTask: Task<Void, Never>?
    
    var filteredGroups: [GroupModel] {
        groups.filter { group in
            let matchesSearch = searchText.isEmpty || group.name.localizedCaseInsensitiveContains(searchText)
            let matchesFilter = selectedSyncFilter == nil || group.syncToSmile == selectedSyncFilter
            return matchesSearch && matchesFilter
        }
    }
    
    func fetchGroups(accessToken: String) async {
        fetchTask?.cancel()
        
        isLoading = true
        error = nil
        
        fetchTask = Task {
            do {
                let response = try await groupService.fetchGroups(accessToken: accessToken)
                if !Task.isCancelled {
                    self.groups = response.items
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                    print("Error fetching groups: \(error)")
                }
            }
            if !Task.isCancelled {
                isLoading = false
            }
        }
        await fetchTask?.value
    }
}
