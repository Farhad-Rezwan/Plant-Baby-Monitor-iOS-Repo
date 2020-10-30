//
//  SuperHero.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import Foundation

class Plant: Codable, Equatable {
    static func == (lhs: Plant, rhs: Plant) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String?
    var name: String = ""
    var location: String = ""
    var image: String = ""
//    var plantStatuses: [PlantStatus] = []

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case location
        case image
//        case plantStatuses
    }
}

