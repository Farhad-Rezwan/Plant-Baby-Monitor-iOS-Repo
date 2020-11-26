//
//  Team.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import Foundation

/// simple user model class
class User {
    var id: String?
    /// save email as well
    var name: String = ""
    var plants: [Plant] = []
    init() {
    }
}
