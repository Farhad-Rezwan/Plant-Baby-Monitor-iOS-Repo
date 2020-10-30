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
        static var homeToAddPlantSegue = "homeToAddPlantSegue"
        
    }
    struct Identifier {
        static var plantTableViewCell = "plantCell"
        static var plantTableViewCellNib = "PlantTableViewCell"
        static var plantChartTableCiewCell = "plantChartCell"
        static var plantChartTableCiewNib = "PlantChartTableViewCell"
    }
    
    struct Databae {
        static var defaultUser = "Default User"
        static var tempPlantName = "Plant A" /// 8prnOgEAgJXvDrmzNOP5
        static var plantCollectionName = "plants"
        static var userCollectionName = "users"
        static var plantStatusCollectionName = "plantStatuses"
        
        struct Attributes {
            static var userName = "name"
            static var plants = "plants"
            static var plantStatusMoisture = "moisture"
            static var plantStatusTemperature = "temperature"
            static var plantStatusHumidity = "humidity"
        }
    }
}
