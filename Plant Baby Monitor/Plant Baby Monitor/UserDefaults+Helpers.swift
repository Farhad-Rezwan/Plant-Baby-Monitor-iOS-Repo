//
//  UserDefaults+Helpers.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 22/11/20.
//

import Foundation

/// reference of idea: https://www.youtube.com/watch?v=gjYAIXjpIS8&t=133s
/// userDefaults helper methods
extension UserDefaults {
    
    /// only two keys are used to save data in the user default
    enum UserDefaultKeys: String {
        case isLoggedIn
        case userId
    }
    
    /// set logged in for user
    /// - Parameter value: parameter of wheather the user is logged in or not (true/false)
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: UserDefaultKeys.isLoggedIn.rawValue)
        synchronize()
    }
    
    /// set the current user id
    /// - Parameter userID: string user id
    func setUserId(userID: String) {
        set(userID, forKey: UserDefaultKeys.userId.rawValue)
        synchronize()
    }
    
    /// gets the user id from the user defaults
    /// - Returns: returns the user id
    func getUserId() -> String {
        return string(forKey: UserDefaultKeys.userId.rawValue) ?? " "
    }
    
    /// check if the user is logged in or not
    /// - Returns: returns boolean value of user logged in status
    func isLoggedIn() -> Bool {
        return bool(forKey: UserDefaultKeys.isLoggedIn.rawValue)
    }
}
