//
//  Constant.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

struct K {
    static var appName = "Plant Baby Monitor"
    
    struct Segue {
        static var loginToHomeSegue = "loginToHomeSegue"
        static var registerToHomeSegue = "registerToHomeSegue"
        
    }
    struct Identifier {
        static var plantTableViewCell = "plantCell"
        static var plantTableViewCellNib = "PlantTableViewCell"
    }
    
    struct Databae {
        static var defaultUser = "Default User"
        static var plantCollectionName = "plants"
        static var userCollectionName = "users"
        
        struct Attributes {
            static var userName = "name"
            static var plants = "plants"
        }
    }
}
