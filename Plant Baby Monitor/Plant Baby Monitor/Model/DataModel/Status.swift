//
//  PlantStatus.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 30/10/20.
//

import Foundation

/// data model for Status, Keept it as struct and delegate to CustomStringConvertable, because of the type of data we
/// get from the Realtime database
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
