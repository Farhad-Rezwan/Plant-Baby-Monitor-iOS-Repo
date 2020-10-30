//
//  DatabaseProtocol.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case user
    case plant
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onUserChange(change: DatabaseChange, userPlants: [Plant])
    func onPlantListChange(change: DatabaseChange, plants: [Plant])
}

protocol DatabaseProtocol: AnyObject {
    var defaultUser: User {get}
    
    func cleanup()
    func addPlant(name: String, location: String, image: String) -> Plant
    func addUser(userName: String) -> User
    func addPlantToUser(hero: Plant, user: User) -> Bool
    func deletePlant(hero: Plant)
    func deleteUser(team: User)
    func deletePlantFromTeam(hero: Plant, team: User)
    func addListener(listener: DatabaseListener, userCredentials: String)
    func removeListener(listener: DatabaseListener)
}
