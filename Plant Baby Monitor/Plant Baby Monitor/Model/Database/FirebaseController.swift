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
    
    var plantStatusRef: DatabaseReference?

    var usersRef: CollectionReference?
    var plantList: [Plant]
    var plantStatusList: [Status]
    var defaultUserPlant: Plant
    var USER_PLANT_NAME = K.Databae.tempPlantName
    var DEFAULT_USER_UID = K.Databae.defaultUser

    /// user er email ane, akhane initialize korbo, niche method ase how to fetch for that email id,
    override init() {
        /// firebase appp configuration method to run the fireabse in the app
        FirebaseApp.configure()

        authController = Auth.auth()
        database = Firestore.firestore()
        plantList = [Plant]()
        plantStatusList = [Status]()
        defaultUser = User()
        defaultUserPlant = Plant()
        // defaultPlantStatus = Status(dictionary: [String : Any])
        
        super.init()
    }
    
    
    /// 1
    /// adds reference to the dartabase from firebase firestore.
    /// Innitiates the listeners for user, and starts persing the plant snapshot
    private func setUpPlantListener() {
        plantsRef = database.collection(K.Databae.plantCollectionName)
        plantsRef?.addSnapshotListener({ (querySnapshot, error) in
            if let err = error {
                print("error listening to database collection plants \(err)")
            } else if let querySnapshot = querySnapshot {
                /// 2.
                self.persePlantsSnapshot(snapshot: querySnapshot)
            }
        })
    }
    
    /// 3.
    private func setupUserListener() {
        usersRef = database.collection(K.Databae.userCollectionName)
        usersRef?.whereField(K.Databae.Attributes.userID, isEqualTo: DEFAULT_USER_UID).addSnapshotListener({ (querySnapshot, error) in
            if let err = error {
                print("error \(err)")
            } else if let querySnapshot = querySnapshot, let teamSnapshot = querySnapshot.documents.first {
                /// 4.
                self.parseUserSnapshot(documentSnapshot: teamSnapshot)
            }
        })
    }
    
    /// 5
    /// Setting up to listen plant status from real time database
    private func setupPlantStatusListener() {
        /// sets reference to the database
        plantStatusRef = Database.database().reference()
        /// Obesrve events of single plant status changes
        plantStatusRef?.child("7MBL5Bbt48NnpWcZappr").observeSingleEvent(of: .value, with: { (snapshot) in
          // Get user value
            self.parsePlantStatusSnapshot(documentSnapshot: snapshot)
          // ...
          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    // MARK:- Parse Functions for Firestore Responses
    /// 2. perse plant snapshots
    private func persePlantsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { (change) in
            let plantID = change.document.documentID

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
    
    /// 4.
    private func parseUserSnapshot(documentSnapshot: QueryDocumentSnapshot) {
        defaultUser = User()
        defaultUser.name = documentSnapshot.data()[K.Databae.Attributes.userID] as! String
        defaultUser.id = documentSnapshot.documentID
        print("Default User Id: (FROM FIREBASE CONTROLLER CLASS: 146:) \(defaultUser.id ?? "USER NOT FOUND")")
        
        if let plantReference = documentSnapshot.data()[K.Databae.Attributes.plants] as? [DocumentReference] {
            for reference in plantReference {
                if let plant = getPlantByID(reference.documentID) {
                    defaultUser.plants.append(plant)
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
    
    /// 6
    /// Perse plant status snapshot
    private func parsePlantStatusSnapshot(documentSnapshot: DataSnapshot) {
        let value = documentSnapshot.value as! NSDictionary
        // print(value)
        
        //MARK:- FIX!!!
        
        /// have to be time stamp insted of double
        for key in value.allKeys {
            let s = Status(dictionary: value[key] as! [String: Any])
            plantStatusList.append(s)
        }
        //print("From Firebase COntroller")
        //print(plantStatusList)
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.plantStatus ||
                listener.listenerType == ListenerType.all {
                
                listener.onPlantStatusChange(change: .update, statuses: plantStatusList)
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
        plantsRef = database.collection(K.Databae.plantCollectionName)
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
    
    func addUser(userID: String) -> User {
        /// userRef required becauase the collection will be nill if the app wants to add a user.
        usersRef = database.collection(K.Databae.userCollectionName)
        let user = User()
        user.name = userID
        
        if let teamRef = usersRef?.addDocument(data: [K.Databae.Attributes.userID: userID, K.Databae.Attributes.plants: []]) {
            user.id = teamRef.documentID
        }
        
        return user
    }
    
    func addPlantToUser(plant: Plant, userID: String) -> Bool {
        plantsRef = database.collection(K.Databae.plantCollectionName)
        usersRef = database.collection(K.Databae.userCollectionName)
        guard let plantID = plant.id else {
            return false
        }
        
        if let plantDocument = plantsRef?.document(plantID) {
            usersRef?.document(defaultUser.id!).updateData(
                [K.Databae.Attributes.plants : FieldValue.arrayUnion([plantDocument])]
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
        DEFAULT_USER_UID = userCredentials


        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.user ||
            listener.listenerType == ListenerType.all {
            
            /// HOME VIEW CONTROLLER
            setUpPlantListener()
            setupUserListener()
            
            listener.onUserChange(change: .update, userPlants: defaultUser.plants)
        }
        
        if listener.listenerType == ListenerType.plant ||
            listener.listenerType == ListenerType.all {
            
            ///
            setUpPlantListener()

            
            listener.onPlantListChange(change: .update, plants: plantList)
        }
        if listener.listenerType == ListenerType.plantStatus ||
            listener.listenerType == ListenerType.all {
            
            /// Plant Details View Controller
            setupPlantStatusListener()
            listener.onPlantStatusChange(change: .update, statuses: plantStatusList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    

}
