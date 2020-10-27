//
//  HomeViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit



class HomeViewController: UIViewController, DatabaseListener {
    var listenerType: ListenerType = .plant
    
    func onUserChange(change: DatabaseChange, userPlants: [Plant]) { }
    
    func onPlantListChange(change: DatabaseChange, plants: [Plant]) {
        plant = plants
        print(plant)
        plantTableView.reloadData()
    }
    
    
    var plant: [Plant] = []
    var cellSpacingHeight = 200
    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var addPlantButtonDesign: UIButton!
    @IBOutlet weak var plantTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        plantTableView.dataSource = self
        plantTableView.delegate = self
        title = K.appName
        
        plantTableView.register(UINib(nibName: K.Identifier.plantTableViewCellNib, bundle: nil), forCellReuseIdentifier: K.Identifier.plantTableViewCell)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        addPlantButtonDesign.layer.borderColor = UIColor.black.cgColor
        addPlantButtonDesign.layer.borderWidth = 1
        addPlantButtonDesign.layer.cornerRadius = addPlantButtonDesign.frame.size.height / 10
        loadPlant()
    }
    
    func loadPlant() {
        
    }
    @IBAction func logoutPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        plantTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return plant.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Identifier.plantTableViewCell, for: indexPath) as! PlantTableViewCell
        cell.plantName.text = plant[indexPath.section].name
        cell.plantLocation.text = plant[indexPath.section].location
        cell.plantImage.image = UIImage(named: plant[indexPath.section].image)
        return cell
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
}
