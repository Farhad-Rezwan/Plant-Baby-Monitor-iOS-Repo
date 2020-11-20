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
    
    /// Multclass Delegate Listener
    var listeners = MulticastDelegate<DatabaseListener>()
    var defaultUser: User
    var database: Firestore
    
    // Reference of the database
    /// from Firestore
    var plantsRef: CollectionReference?
    var usersRef: CollectionReference?
    /// from realtime database
    var plantStatusRef: DatabaseReference?
    
    var plantList: [Plant]
    var plantStatusList: [Status]

    /// Constants
    var USER_PLANT_NAME = K.Databae.tempPlantName
    var DEFAULT_USER_UID = K.Databae.defaultUser

    /// user er email ane, akhane initialize korbo, niche method ase how to fetch for that email id,
    override init() {
        /// firebase appp configuration method to run the fireabse in the app
        FirebaseApp.configure()
        database = Firestore.firestore()
        
        plantList = [Plant]()
        plantStatusList = [Status]()
        defaultUser = User()
        super.init()
    }
    
    //MARK:- Methods for listenrs
    
    /// Sets up plant listener - Listens from firestore changes of collection - Plants
    private func setUpPlantListener() {
        plantsRef = database.collection(K.Databae.plantCollectionName)
        plantsRef?.addSnapshotListener({ (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("error listening to database collection plants \(error!)")
                return
            }
            self.persePlantsSnapshot(snapshot: querySnapshot)
        })
    }
    
    /// Sets up user listener - Listenes form firestore changes of collection - Users
    private func setupUserListener() {
        usersRef = database.collection(K.Databae.userCollectionName)
        usersRef?.whereField(K.Databae.Attributes.userID, isEqualTo: DEFAULT_USER_UID).addSnapshotListener({ (querySnapshot, error) in
            guard let snapshot = querySnapshot, let userSnapshot = snapshot.documents.first else {
                print("error fetching databse collection user \(error!)")
                return
            }
            self.parseUserSnapshot(documentSnapshot: userSnapshot)
        })
    }
    
    /// sets up plant status listener - LIstens from realtime database changes of collection - plant status
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
    
    
    // MARK:- Parse Functions for cloud responses
    /// Perse plant snapshots, and invokes listeners for any plant changes
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
            
            /// functions based on change functionalities
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
    
    /// Perse user snapshots, and invokes listeners for any user changes
    private func parseUserSnapshot(documentSnapshot: QueryDocumentSnapshot) {
        defaultUser = User()
        defaultUser.name = documentSnapshot.data()[K.Databae.Attributes.userID] as! String
        defaultUser.id = documentSnapshot.documentID
        
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
    
    /// Perse plant status snapshot, invokes listeners for any plant status changes
    private func parsePlantStatusSnapshot(documentSnapshot: DataSnapshot) {
        plantStatusList.removeAll()
        let value = documentSnapshot.value as! NSDictionary
        // print(value)
        
        for key in value.allKeys {
            let s = Status(dictionary: value[key] as! [String: Any])
            plantStatusList.append(s)
        }
        
        //print(plantStatusList)
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.plantStatus ||
                listener.listenerType == ListenerType.all {
                
                listener.onPlantStatusChange(change: .update, statuses: plantStatusList)
            }
        }
    }
    
    /// gets plants index by id provided.
    /// - Parameter id: stirng id
    /// - Returns: returns first index of the plant
    private func getPlantIndexByID(_ id: String) -> Int? {
        if let plant = getPlantByID(id) {
            return plantList.firstIndex(of: plant)
        }
        return nil
    }
    
    /// gets plant by id
    /// - Parameter id: plant id
    /// - Returns: returns a particular plant
    private func getPlantByID(_ id: String) -> Plant? {
        for plant in plantList {
            if plant.id == id {
                return plant
            }
        }
        return nil
    }
    
    func cleanup() {
        // does nothing
    }
    
    /// Adds pant in the firebase
    /// - Parameters:
    ///   - name: name of the plant
    ///   - location: location of the plant
    ///   - image: iamge url of the plant
    /// - Returns: returns plant which is saved in the firebase
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
    
    /// Adds user in the firebase
    /// - Parameter userID: user credential id
    /// - Returns: returns users as saved in the firebase
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
    
    /// Adds plant for the user
    /// - Parameters:
    ///   - plant: Plant object
    ///   - userID: User credentials
    /// - Returns: returns true if the plant is successfully added, otherwise returns false
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
    
    /// Deletes a partuclar plant by id
    /// - Parameter plant: Plant to be deleted from the firestore
    func deletePlant(plant: Plant) {
        if let plantID = plant.id {
            plantsRef?.document(plantID).delete()
        }
    }
    
    /// Deletes a particular user by id
    /// - Parameter user: User to be deleted from the firestore
    func deleteUser(user: User) {
        if let userID = user.id {
            usersRef?.document(userID).delete()
        }
    }
    
    /// Deletes a particular plant for the user from firestore
    /// - Parameters:
    ///   - plant: Plant to be deleted
    ///   - user: user of whoom the plant to be deleted
    func deletePlantFromUser(plant: Plant, user: User) {
        if user.plants.contains(plant), let userID = user.id, let plantID = plant.id {
            if let removedRef = plantsRef?.document(plantID) {
                usersRef?.document(userID).updateData(
                    [K.Databae.plantCollectionName : FieldValue.arrayRemove([removedRef])]
                )
            }
        }
    }
    
    /// Adds LIsteners depending on listerner type (user, plant or plant status)
    /// - Parameters:
    ///   - listener: enum lsitener can be user/plant or plantStatus
    ///   - userCredentials: users Credential of whoom the plant or plant status is shown
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
    
    /// Removes the lsiterners, to stop listening for database change
    /// - Parameter listener: Listener to be removed
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
        plantStatusRef?.removeAllObservers()
        
    }
}
