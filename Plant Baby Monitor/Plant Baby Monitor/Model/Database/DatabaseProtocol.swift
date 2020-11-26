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
    case plantStatus
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onUserChange(change: DatabaseChange, userPlants: [Plant])
    func onPlantListChange(change: DatabaseChange, plants: [Plant])
    func onPlantStatusChange(change: DatabaseChange, statuses: [Status])
}

protocol DatabaseProtocol: AnyObject {
    var defaultUser: User {get}
    
    func cleanup()
    func addPlant(name: String, location: String, image: String) -> Plant
    func addUser(userID: String) -> User
    func addPlantToUser(plant: Plant, userID: String) -> Bool
    func deletePlant(plant: Plant)
    func deleteUser(user: User)
    func deletePlantFromUser(plant: Plant, userId: String)
    func addListener(listener: DatabaseListener, userCredentials: String, plantID: String)
    func removeListener(listener: DatabaseListener)
    func updateUserPlant(newPlant: Plant)
}
