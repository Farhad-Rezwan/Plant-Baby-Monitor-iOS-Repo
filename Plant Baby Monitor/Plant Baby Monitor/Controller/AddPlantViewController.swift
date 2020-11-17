//
//  AddPlantViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import UIKit

class AddPlantViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var userDocumentID: String?
    
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var plantImageTextField: UITextField!
    @IBOutlet weak var plantLocationTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        
        // Adds the delegate for database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    @IBAction func addPlantButtonAction(_ sender: Any) {
        if plantNameTextField.text != "" && plantImageTextField.text != "" && plantLocationTextField.text != "" {
            let name = plantNameTextField.text!
            let image = plantImageTextField.text!
            let location = plantLocationTextField.text!
            
            let plantToStore: Plant = (databaseController?.addPlant(name: name, location: location, image: image))!
            
            // plant to be stored for user id
            let _ = databaseController?.addPlantToUser(plant: plantToStore, userID: userDocumentID!)
            navigationController?.popViewController(animated: true)
            return
        }
    }
}
