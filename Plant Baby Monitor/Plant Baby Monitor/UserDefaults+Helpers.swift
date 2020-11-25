//
//  UserDefaults+Helpers.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 22/11/20.
//

import Foundation


extension UserDefaults {
    
    enum UserDefaultKeys: String {
        case isLoggedIn
        case userId
    }
    
    
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    func setUserId(userID: String) {
        set(userID, forKey: UserDefaultKeys.userId.rawValue)
        synchronize()
    }
    
    func getUserId() -> String {
        return string(forKey: UserDefaultKeys.userId.rawValue) ?? " "
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultKeys.isLoggedIn.rawValue)
    }
}
