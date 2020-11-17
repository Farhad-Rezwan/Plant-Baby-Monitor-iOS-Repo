//
//  HomeViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit
import AWSIoT
import AWSMobileClient


class HomeViewController: UIViewController, DatabaseListener {


    @IBOutlet weak var addPlantButtonDesign: UIButton!
    @IBOutlet weak var plantTableView: UITableView!
    @objc var iotDataManager: AWSIoTDataManager!

    weak var databaseController: DatabaseProtocol?
    var uID: String?
    var user: User?
    var listenerType: ListenerType = .user
    var plant: [Plant] = []
    var cellSpacingHeight = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adding table view delegates
        plantTableView.dataSource = self
        plantTableView.delegate = self
        
        title = K.appName

        /// registeres the custom plat cell
        plantTableView.register(UINib(nibName: K.Identifier.plantTableViewCellNib, bundle: nil), forCellReuseIdentifier: K.Identifier.plantTableViewCell)
        
        /// assigns the database delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        /// designing the plant add button
        addPlantButtonDesign.layer.borderColor = UIColor.black.cgColor
        addPlantButtonDesign.layer.borderWidth = 1
        addPlantButtonDesign.layer.cornerRadius = addPlantButtonDesign.frame.size.height / 10
    }
    
    /// once the logout button is pressed the user is navigated to the root view controller
    @IBAction func logoutPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    /// adds the users listener when the view is loaded
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self, userCredentials: uID!)
        plantTableView.reloadData()
    }
    
    /// removes the user's listener when the view is no longer visable
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.homeToAddPlantSegue {
            let destination = segue.destination as! AddPlantViewController
            destination.userDocumentID = uID
        }
    }
    
    // MARK:- Listener Methods
    func onUserChange(change: DatabaseChange, userPlants: [Plant]) {
        print("User listener listening")
        plant = userPlants
        plantTableView.reloadData()
    }
    /// do nothing
    func onPlantStatusChange(change: DatabaseChange, statuses: [Status]) { }
    
    /// do nothing
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) { }
    
    
}

/// Table view to show the plants of user
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    // using section insted of row, so that the cell difference is significant
    func numberOfSections(in tableView: UITableView) -> Int {
        return plant.count
    }
    
    // per section will have one plant
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // designing the cell using custom cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifier.plantTableViewCell, for: indexPath) as! PlantTableViewCell
        cell.plantName.text = plant[indexPath.section].name
        cell.plantLocation.text = plant[indexPath.section].location
        cell.plantImage.image = UIImage(named: plant[indexPath.section].image)
        return cell
    }
    
    
    /// navigate to chars view when any of the plat is selected - Should show plant information
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(identifier: K.Identifier.plantChartDetailsViewController) as! ChartsViewController
        
        viewController.plant = plant[indexPath.section]
        viewController.uID = uID
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

