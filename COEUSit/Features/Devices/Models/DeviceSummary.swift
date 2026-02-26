//
//  DeviceSummary.swift
//  COEUSit
//

import Foundation

struct DeviceSummary: Codable {
    let device: SummaryDevice
    let window: SummaryWindow
    let stats: SummaryStats?
    let records: [DeviceRecord]?
}

struct SummaryDevice: Codable {
    let id: String
    let name: String?
    let serialNumber: String
    let temperatureUnit: String
    let timezone: String
    let batteryPercent: Int
    let charging: Bool
    let online: Bool

    enum CodingKeys: String, CodingKey {
        case id, name, timezone, charging, online
        case serialNumber = "serial_number"
        case temperatureUnit = "temperature_unit"
        case batteryPercent = "battery_percent"
    }
}

struct SummaryWindow: Codable {
    let start: String
    let end: String
}

struct SummaryStats: Codable {
    let min: StatDetail?
    let max: StatDetail?
    let avgTemp: Double?
    let avgHumidity: Double?

    enum CodingKeys: String, CodingKey {
        case min, max
        case avgTemp = "avg_temp"
        case avgHumidity = "avg_humidity"
    }
}

struct StatDetail: Codable {
    let time: String?
    let temperature: Double?
    let humidity: Double?
    let probeType: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case time, temperature, humidity, status
        case probeType = "probe_type"
    }
}

struct DeviceRecord: Codable, Identifiable {
    let id: UUID
    let time: String?
    let temperature: Double?
    let humidity: Double?
    let probeType: String?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case time, temperature, humidity, status
        case probeType = "probe_type"
    }
    
    var date: Date? {
        guard let time = time else { return nil }
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: time)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        time = try container.decodeIfPresent(String.self, forKey: .time)
        temperature = try container.decodeIfPresent(Double.self, forKey: .temperature)
        humidity = try container.decodeIfPresent(Double.self, forKey: .humidity)
        probeType = try container.decodeIfPresent(String.self, forKey: .probeType)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        id = UUID() // Generate once on decode
    }
}
