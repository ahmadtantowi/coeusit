//
//  COEUSitApp.swift
//  COEUSit
//
//  Created by eMade on 25/02/26.
//

import SwiftUI

@main
struct COEUSitApp: App {
    @StateObject private var authManager = AuthManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
