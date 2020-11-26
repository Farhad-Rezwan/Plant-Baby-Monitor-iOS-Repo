//
//  EditPlantViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 21/11/20.
//

import UIKit

protocol ReloadDataAfterEdit {
    func didFinishEditing()
}

class EditPlantViewController: UIViewController {
    
    var plant: Plant?
    var uID: String?
    let plantImageArray = ["pa", "pb", "pc"]
    var plantImageName: String?
    var selectedIndexPath: IndexPath?
    weak var databaseController: DatabaseProtocol?
    var delegateForEdit: ReloadDataAfterEdit?
    
    @IBOutlet weak var plantBackgroundImage: UIImageView!
    @IBOutlet weak var plantImageCollectionView: UICollectionView!
    @IBOutlet weak var plantNameEditTextField: UITextField!
    @IBOutlet weak var plantLocationEditTextField: UITextField!
    @IBOutlet weak var editPlantUIButton: UIButton!
    @IBOutlet weak var deletePlantUIButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tap on the text field to edit"
        
        plantImageCollectionView.dataSource = self
        plantImageCollectionView.delegate = self
        
        // Adds the delegate for database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        /// adding the plant background image, the image that showcase which one is user already selected
        plantBackgroundImage.image = UIImage(named: plant?.image ?? "pa")
        
        
        /// assigning the delegates for textfields
        plantNameEditTextField.delegate = self
        plantLocationEditTextField.delegate = self
    
        guard let plantName = plant?.name, let plantLocation = plant?.location, let plantImage = plant?.image else { return }
        
        plantNameEditTextField.placeholder = ("name: \(plantName)")
        plantLocationEditTextField.placeholder = ("location: \(plantLocation)")
        plantImageName = plantImage
        
        // Do any additional setup after loading the view.
        /// helps to decorate buttons when the view did load
        decorateUIButtons()
    }
    
    
    /// Function to help decorate buttons for the current view controller
    private func decorateUIButtons() {
        /// Make the button round with
        editPlantUIButton.layer.cornerRadius = 40
        deletePlantUIButton.layer.cornerRadius = 40
    }

    
    
    /// Function to save once the editing of the plant is done
    /// validates properly with alert as well
    @IBAction func saveEditingPantTapped(_ sender: Any) {
        /// gives user with selection haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        let newPlant = plant
        var edited: Bool = false
        
        let trimmedPlantName = plantNameEditTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPlantLocation = plantLocationEditTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        if plantNameEditTextField.hasText == true && trimmedPlantName != "" {
            newPlant?.name = plantNameEditTextField.text!
            edited = true
        }
        
        if plantLocationEditTextField.hasText == true && trimmedPlantLocation != "" {
            newPlant?.location = plantLocationEditTextField.text!
            edited = true
        }
        
        if selectedIndexPath != nil {
            newPlant?.image = plantImageArray[selectedIndexPath!.row]
            edited = true
        }
        

        if edited == true {
            let _ = databaseController?.updateUserPlant(newPlant: newPlant!)
        } else {
            
            /// alert for handling if thhere is no change made
            let alertController = UIAlertController(title: "No change made", message: "Do you want to exit?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Change Attributes", style: UIAlertAction.Style.default, handler: nil))
            alertController.addAction(UIAlertAction(title: "Exit", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                
                self.delegateForEdit?.didFinishEditing()
                self.dismiss(animated: true, completion: nil)
                return
                    
            }))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        delegateForEdit?.didFinishEditing()
        dismiss(animated: true, completion: nil)
    }
    
    /// delete plant with options
    @IBAction func deletePlantTapped(_ sender: Any) {
        /// gives user with selection haptic feedback
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
        
        guard let plantToDelete = plant, let userIDOfPlantToDelete = uID else {
            
            // alert for issue relates to nil values
            let alertController = UIAlertController(title: "Something Wrong Happend", message: "Cannot delete the plant due to unavoidable reason", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        
        // alert for issue relates to nil values
        let alertController = UIAlertController(title: "Delete Plant: \(plant?.name ?? " ")", message: "Are you sure you want to delete this plant", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertAction.Style.default, handler: { (action) in
            self.databaseController?.deletePlantFromUser(plant: plantToDelete, userId: userIDOfPlantToDelete)
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)

        
        
    }
    
    @IBAction func dismissViewButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

/// collection view datasource and delegate methods for the plant image for user to choose from
extension EditPlantViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
        plantBackgroundImage.image = UIImage(named: plantImageArray[indexPath.row])
        print("selected", plantImageArray[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? PlantImageCell else { return }
        redraw(deselectedCell: cell)
        selectedIndexPath = nil
        plantBackgroundImage.image = UIImage(named: plantImageName ?? "pa")
        print("Deselected", plantImageArray[indexPath.row])
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

/// delegate method for textfields
extension EditPlantViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// when user presses anywhere else other than keyboard the keyboard will hide
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
