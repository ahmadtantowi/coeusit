//
//  Group.swift
//  COEUSit
//

import Foundation

struct GroupModel: Codable, Identifiable {
    let id: String
    let name: String
    let description: String?
    let smileEntityId: Int?
    let locationLongitude: Double?
    let locationLatitude: Double?
    let syncToSmile: Bool
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description
        case smileEntityId = "smile_entity_id"
        case locationLongitude = "location_longitude"
        case locationLatitude = "location_latitude"
        case syncToSmile = "sync_to_smile"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct GroupResponse: Codable {
    let items: [GroupModel]
}
