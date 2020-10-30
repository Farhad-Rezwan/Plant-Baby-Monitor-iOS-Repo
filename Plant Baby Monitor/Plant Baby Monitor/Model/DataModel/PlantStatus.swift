//
//  PlantStatus.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 30/10/20.
//

import Foundation

class PlantStatus: Codable, Equatable {
    static func == (lhs: PlantStatus, rhs: PlantStatus) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var moisture: String = ""
    var temperature: String = ""
    var humidity: String = ""

    enum CodingKeys: String, CodingKey {
        case id
        case moisture
        case temperature
        case humidity
    }
}
