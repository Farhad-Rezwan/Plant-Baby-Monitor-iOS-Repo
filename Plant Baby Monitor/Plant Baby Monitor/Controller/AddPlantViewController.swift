//
//  AddPlantViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import UIKit

class AddPlantViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var uID: String?
    
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var plantImageTextField: UITextField!

    @IBOutlet weak var plantLocationTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    @IBAction func addPlantButtonAction(_ sender: Any) {
        if plantNameTextField.text != "" && plantImageTextField.text != "" && plantLocationTextField.text != "" {
            let name = plantNameTextField.text!
            let image = plantImageTextField.text!
            let location = plantLocationTextField.text!
            var plantSatuses: [PlantStatus] = []
            var plant = Plant()
            plant.name = name
            plant.location = location
            plant.image = image
            var a = PlantStatus()
            a.humidity = "0.10"
            a.temperature = "30.0"
            a.moisture = "6.03"
            var b = PlantStatus()
            b.humidity = "1.10"
            b.temperature = "31.0"
            b.moisture = "6.04"
            var c = PlantStatus()
            c.humidity = "2.10"
            c.temperature = "32.0"
            c.moisture = "5.04"
            plantSatuses.append(contentsOf: [a,b,c])
//            plant.plantStatuses = plantSatuses
            
//            let _ = databaseController?.addPlantToUser(hero: plantSatuses, user: <#T##User#>)

            let _ = databaseController?.addPlant(name: name, location: location, image: image)
            navigationController?.popViewController(animated: true)
            return
        }
    }
}
