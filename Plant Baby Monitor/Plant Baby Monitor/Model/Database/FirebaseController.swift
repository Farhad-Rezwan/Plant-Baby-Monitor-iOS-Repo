//
//  File.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import Foundation

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var defaultUser: User
    var authController: Auth
    var database: Firestore
    var plantsRef: CollectionReference?
    var usersRef: CollectionReference?
    var plantStatusRef: CollectionReference?
    var plantList: [Plant]
    var plantStatusList: [PlantStatus]
    var defaultUserPlant: Plant
    var USER_PLANT_NAME = K.Databae.tempPlantName
    let DEFAULT_USER_NAME = K.Databae.defaultUser

    /// user er email ane, akhane initialize korbo, niche method ase how to fetch for that email id,
    override init() {
        /// firebase appp configuration method to run the fireabse in the app
        FirebaseApp.configure()
        authController = Auth.auth()
        database = Firestore.firestore()
        plantList = [Plant]()
        plantStatusList = [PlantStatus]()
        defaultUser = User()
        defaultUserPlant = Plant()
        
        super.init()

        // sign in an annonymous account
        
//        authController.signInAnonymously { (authResult, error) in
//            if let err = error {
//                print("error sign in annonymously \(err)")
//            } else {
//
//            }
//        }
        
//        let email = "click9417@gmail.com"
//        let password = "Sf_01671119079"
//            
//        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
//            if let err = error {
//                print(err)
//            } else {
//                self.setUpPlantListener()
//            }
//        }
        
    }
    
    private func setUpPlantListener() {
        plantsRef = database.collection(K.Databae.plantCollectionName)
        plantsRef?.addSnapshotListener({ (querySnapshot, error) in
            if let err = error {
                print("error listening to database collection plants \(err)")
            } else if let querySnapshot = querySnapshot {
                self.persePlantsSnapshot(snapshot: querySnapshot)
                self.setupUserListener()
            }
        })
    }
    private func setupUserListener() {
        usersRef = database.collection(K.Databae.userCollectionName)
        usersRef?.whereField(K.Databae.Attributes.userName, isEqualTo: DEFAULT_USER_NAME).addSnapshotListener({ (querySnapshot, error) in
            if let err = error {
                print("error \(err)")
            } else if let querySnapshot = querySnapshot, let teamSnapshot = querySnapshot.documents.first {
                self.perseTeamSnapshot(documentSnapshot: teamSnapshot)
            }
        })
    }
    
    // MARK:- Parse Functions for Firestore Responses
    private func persePlantsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let plantID = change.document.documentID
            print(plantID)
            
            var parsePlant: Plant?
            
            do{
                parsePlant = try change.document.data(as: Plant.self)
            } catch {
                print("Unable to decode plant")
                return
            }
            
            guard let plant = parsePlant else {
                print("Document doesnot exist")
                return
            }
            
            plant.id = plantID
            
            switch change.type {
            case .added:
                plantList.append(plant)
                break
            case .modified:
                let index = getPlantIndexByID(plantID)!
                plantList[index] = plant
                break
            case .removed:
                if let index = getPlantIndexByID(plantID) {
                    plantList.remove(at: index)
                }
                break
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.plant ||
                    listener.listenerType == ListenerType.all {
                    listener.onPlantListChange(change: .update, plants: plantList)
                }
            }
        }
        
    }
    private func perseTeamSnapshot(documentSnapshot: QueryDocumentSnapshot) {
        defaultUser = User()
        defaultUser.name = documentSnapshot.data()[K.Databae.Attributes.userName] as! String
        defaultUser.id = documentSnapshot.documentID
        
        if let heroReferences = documentSnapshot.data()[K.Databae.Attributes.plants] as? [DocumentReference] {
            for reference in heroReferences {
                if let hero = getPlantByID(reference.documentID) {
                    defaultUser.plants.append(hero)
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.user ||
                listener.listenerType == ListenerType.all {
                
                listener.onUserChange(change: .update, userPlants: defaultUser.plants)
            }
        }
        
    }
    
    private func getPlantIndexByID(_ id: String) -> Int? {
        if let plant = getPlantByID(id) {
            return plantList.firstIndex(of: plant)
        }
        return nil
    }
    
    private func getPlantByID(_ id: String) -> Plant? {
        for plant in plantList {
            if plant.id == id {
                return plant
            }
        }
        return nil
    }
    
    func cleanup() {
        
    }
    
    func addPlant(name: String, location: String, image: String) -> Plant {
        let plant = Plant()
        plant.name = name
        plant.location = location
        plant.image = image
        
        do {
            if let heroRef = try plantsRef?.addDocument(from: plant) {
                plant.id = heroRef.documentID
            }
        } catch {
            print("Failed to serialize hero")
        }
        return plant
    }
    
    func addUser(userName: String) -> User {
        let team = User()
        team.name = userName
        
        if let teamRef = usersRef?.addDocument(data: ["name": userName, "heroes": []]) {
            team.id = teamRef.documentID
        }
        
        return team
    }
    
    func addPlantToUser(hero: Plant, user: User) -> Bool {
        guard let heroID = hero.id, let teamID = user.id, user.plants.count < 6 else {
            return false
        }
        
        if let newHeroRef = plantsRef?.document(heroID) {
            usersRef?.document(teamID).updateData(
                [K.Databae.Attributes.plants : FieldValue.arrayUnion([newHeroRef])]
            )
        }
        return true
    }
    
    func deletePlant(hero: Plant) {
        if let heroID = hero.id {
            plantsRef?.document(heroID).delete()
        }
    }
    
    func deleteUser(team: User) {
        if let teamID = team.id {
            usersRef?.document(teamID).delete()
        }
    }
    
    func deletePlantFromTeam(hero: Plant, team: User) {
        if team.plants.contains(hero), let teamID = team.id, let heroID = hero.id {
            if let removedRef = plantsRef?.document(heroID) {
                usersRef?.document(teamID).updateData(
                    [K.Databae.plantCollectionName : FieldValue.arrayRemove([removedRef])]
                )
            }
        }
    }
    
    func addListener(listener: DatabaseListener, userCredentials: String) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.user ||
            listener.listenerType == ListenerType.all {
            listener.onUserChange(change: .update, userPlants: defaultUser.plants)
        }
        
        if listener.listenerType == ListenerType.plant ||
            listener.listenerType == ListenerType.all {
            listener.onPlantListChange(change: .update, plants: plantList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    

}
