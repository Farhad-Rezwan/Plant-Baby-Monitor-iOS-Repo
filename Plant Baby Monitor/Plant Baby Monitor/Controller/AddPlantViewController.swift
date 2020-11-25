//
//  AddPlantViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 27/10/20.
//

import UIKit

class AddPlantViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var delegateForEdit: ReloadDataAfterEdit?
    var userDocumentID: String?
    let plantImageArray = ["pa", "pb", "pc"]
    var selectedIndexPath: IndexPath?

    
    @IBOutlet weak var plantImageCollectionView: UICollectionView!
    @IBOutlet weak var plantNameTextField: UITextField!
    @IBOutlet weak var plantLocationTextField: UITextField!
    @IBOutlet weak var addPlantUIButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        
        plantImageCollectionView.dataSource = self
        plantImageCollectionView.delegate = self
        
        plantNameTextField.delegate = self
        plantLocationTextField.delegate = self
        
        // Adds the delegate for database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        /// helps to decorate buttons when the view did load
        decorateUIButtons()
    }
    
    /// Function to help decorate buttons for the current view controller
    private func decorateUIButtons() {
        /// Make the button round with
        addPlantUIButton.layer.cornerRadius = 40
    }

    @IBAction func addPlantButtonAction(_ sender: Any) {
        /// making sure user name has no spaces, also validates user name, if empty provides message
        let trimmedPlantName = plantNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlantLocation = plantLocationTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedPlantName != "" && trimmedPlantLocation != "" && selectedIndexPath != nil {
            let name = plantNameTextField.text!
            let image = plantImageArray[selectedIndexPath!.row]
            let location = plantLocationTextField.text!
            
            let plantToStore: Plant = (databaseController?.addPlant(name: name, location: location, image: image))!
            
            // plant to be stored for user id
            let _ = databaseController?.addPlantToUser(plant: plantToStore, userID: userDocumentID!)
            delegateForEdit?.didFinishEditing()
            dismiss(animated: true, completion: nil)
            return
        }
        var errorMessage = "Please ensure all fields are filled: \n"
        
        if trimmedPlantName == "" {
            errorMessage += "-must provide plant name\n"
        }

        if trimmedPlantLocation == "" {
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
    
    @IBAction func closeViewbuttonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension AddPlantViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Identifier.plantImageCell, for: indexPath) as! PlantImageCell
        
        cell.plantCellImageView.image = UIImage(named: plantImageArray[indexPath.row])
        
        if cell.isSelected == true {
            redraw(selectedCell: cell)
        } else {
            redraw(deselectedCell: cell)
        }
        
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
        cell.isSelected = true
        cell.layer.borderWidth = 4.0
        cell.layer.cornerRadius = 10
        cell.layer.borderColor = UIColor.systemGreen.cgColor
    }

    /// removes boarder if the cell is selected
    /// - Parameter cell: collection view cell
    private func redraw(deselectedCell cell: PlantImageCell) {
        cell.isSelected = false
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.systemGroupedBackground.cgColor

    }

}

extension AddPlantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// when user presses anywhere else other than keyboard the keyboard will hide
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
