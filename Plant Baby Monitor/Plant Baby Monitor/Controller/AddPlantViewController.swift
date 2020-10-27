//
//  AddPlantViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import UIKit

class AddPlantViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    
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
            let _ = databaseController?.addPlant(name: name, location: location, image: image)
            navigationController?.popViewController(animated: true)
            return
        }
    }
}
