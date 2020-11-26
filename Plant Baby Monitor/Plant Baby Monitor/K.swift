//
//  Constant.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

/// all the constants are stored here, the names are kept self explanatory
struct K {
    static var appName = "Plant Baby Monitor"
    static var defaultFont = "Chalkboard SE Regular"
    static var logoImage = "Logo"
    
    struct Segue {
        static var loginToHomeSegue = "loginToHomeSegue"
        static var registerToHomeSegue = "registerToHomeSegue"

    }
    struct Identifier {
        static var plantTableViewCell = "plantCell"
        static var plantTableViewCellNib = "PlantTableViewCell"
        static var plantChartTableCiewCell = "plantChartCell"
        static var plantChartTableCiewNib = "PlantChartTableViewCell"
        static var plantChartDetailsViewController = "plantDetailsVC"
        static var plantImageCell = "plantImageCell"
        static var editPlantViewController = "editPlantViewController"
        static var homeViewController = "homeViewControllerID"
        static var welcomeViewController = "welclomeViewController"
        static var addPlantViewController = "addPlantViewController"
    }
    
    struct Databae {
        static var defaultUser = "Default User"
        static var plantCollectionName = "plants"
        static var userCollectionName = "users"
        static var plantStatusCollectionName = "plantStatuses"
        
        struct Attributes {
            static var userName = "userIdentity"
            static var plantName = "name"
            static var plantLocation = "location"
            static var plantImage = "image"
            static var plants = "plants"
            static var plantStatusMoisture = "moisture"
            static var plantStatusTemperature = "temperature"
            static var plantStatusHumidity = "humidity"
        }
    }
    
    struct Colors {
        static var buttonTxtColor = "DGreen"
        static var backgrondColor = "AppHeader"
    }
}
