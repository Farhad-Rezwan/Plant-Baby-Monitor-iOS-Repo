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
    let plantImageArray = ["pa", "pb", "pc"]
    var selectedIndexPath: IndexPath?

    
    @IBOutlet weak var plantImageCollectionView: UICollectionView!
//    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var plantLocationTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        
        plantImageCollectionView.dataSource = self
        plantImageCollectionView.delegate = self
        
        // Adds the delegate for database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    @IBAction func addPlantButtonAction(_ sender: Any) {
        if plantNameTextField.text != "" && plantLocationTextField.text != "" && selectedIndexPath != nil {
            let name = plantNameTextField.text!
            let image = plantImageArray[selectedIndexPath!.row]
            let location = plantLocationTextField.text!
            
            let plantToStore: Plant = (databaseController?.addPlant(name: name, location: location, image: image))!
            
            // plant to be stored for user id
            let _ = databaseController?.addPlantToUser(plant: plantToStore, userID: userDocumentID!)
            navigationController?.popViewController(animated: true)
            return
        }
        var errorMessage = "Please ensure all fields are filled: \n"
        
        if plantNameTextField.text == "" {
            errorMessage += "-must provide plant name\n"
        }

        if plantLocationTextField.text == "" {
            errorMessage += "-must provide plant location\n"
        }
        
        if selectedIndexPath == nil {
            errorMessage += "-must select a plant image\n"
        }
        

        displayMessage(title: "Not all fields filled", message: errorMessage)
    }
    
    /// Displays Alert for invalid infomation
    /// - Parameters:
    ///   - title: the title of the alert
    ///   - message: message of the allert
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AddPlantViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Identifier.plantImageCell, for: indexPath) as! PlantImageCell
        
        cell.plantCellImageView.image = UIImage(named: plantImageArray[indexPath.row])
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.systemGroupedBackground.cgColor

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PlantImageCell else { return }
        redraw(selectedCell: cell)
        selectedIndexPath = indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PlantImageCell else { return }
        redraw(deselectedCell: cell)
        selectedIndexPath = nil
    }

    
    /// reference for both method: https://stackoverflow.com/questions/44205550/select-only-one-item-in-uicollectionviewcontroller
    // makes boarder if the cell is selected
    /// - Parameter cell: collection view cell
    private func redraw(selectedCell cell: PlantImageCell
            ) {
        cell.layer.borderWidth = 4.0
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.systemGreen.cgColor
    }

    /// removes boarder if the cell is selected
    /// - Parameter cell: collection view cell
    private func redraw(deselectedCell cell: PlantImageCell) {
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.systemGroupedBackground.cgColor

    }
    

    
    
}
