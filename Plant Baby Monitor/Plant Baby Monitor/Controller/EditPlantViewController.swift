//
//  EditPlantViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 21/11/20.
//

import UIKit

class EditPlantViewController: UIViewController {
    
    var plant: Plant?
    var uID: String?
    let plantImageArray = ["pa", "pb", "pc"]
    var plantImageName: String?
    var selectedIndexPath: IndexPath?
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var plantBackgroundImage: UIImageView!
    @IBOutlet weak var plantImageCollectionView: UICollectionView!
    @IBOutlet weak var plantNameEditTextField: UITextField!
    @IBOutlet weak var plantLocationEditTextField: UITextField!
    @IBOutlet weak var editPlantUIButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tap on the text field to edit"
        
        plantImageCollectionView.dataSource = self
        plantImageCollectionView.delegate = self
        
        // Adds the delegate for database
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController

        plantBackgroundImage.image = UIImage(named: plant?.image ?? "pa")
        
        
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
    }

    
    
    
    @IBAction func saveEditingPantTapped(_ sender: Any) {
        let newPlant = plant
        var edited: Bool = false
        
        if plantNameEditTextField.hasText == true {
            newPlant?.name = plantNameEditTextField.text!
            edited = true
        }
        
        if plantLocationEditTextField.hasText == true {
            newPlant?.location = plantLocationEditTextField.text!
            edited = true
        }
        
        if selectedIndexPath != nil {
            newPlant?.image = plantImageArray[selectedIndexPath!.row]
            edited = true
        }
        
        if edited == true {
            let _ = databaseController?.updateUserPlant(newPlant: newPlant!)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension EditPlantViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return plantImageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: K.Identifier.plantImageCell, for: indexPath) as! PlantImageCell
        
        cell.plantCellImageView.image = UIImage(named: plantImageArray[indexPath.row])
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
