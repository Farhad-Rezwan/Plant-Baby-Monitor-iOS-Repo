//
//  PlantStatus.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 30/10/20.
//

import Foundation

//class PlantStatus: Codable, Equatable {
//    static func == (lhs: PlantStatus, rhs: PlantStatus) -> Bool {
//        return lhs.id == rhs.id
//    }
//
//    var id: String?
//    var moisture: String = ""
//    var temperature: String = ""
//    var humidity: String = ""
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case moisture
//        case temperature
//        case humidity
//    }
//}
struct Status: CustomStringConvertible {
    let humid: Double
    let moist: Double
    let temp: Double
    let timeStamp: Double

    init(dictionary: [String: Any]) {
        self.humid = dictionary["humid"] as? Double ?? 0
        self.moist = dictionary["moist"] as? Double ?? 0
        self.temp = dictionary["temp"] as? Double ?? 0
        self.timeStamp = dictionary["timestamp"] as? Double ?? 0
    }
    
    var description: String {
        return "Humid#: " + String(humid) + " - name: " +  String(moist) + " - temp: " +  String(temp) + " - temeStamp: " +  String(timeStamp)
    }
}
