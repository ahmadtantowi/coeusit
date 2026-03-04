//
//  UserProfile.swift
//  COEUSit
//

import Foundation

struct UserProfile: Codable {
    let id: UUID
    let email: String
    let name: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id, email
        case name, role
    }
}
