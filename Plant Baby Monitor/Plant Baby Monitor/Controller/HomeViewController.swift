//
//  HomeViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit

class Plant {
    var name: String?
    var location: String?
    var image: String?
    init(name: String, location: String, image: String) {
        self.name = name
        self.image = image
        self.location = location
    }
}

class HomeViewController: UIViewController {
    
    var plant: [Plant] = []
    var cellSpacingHeight = 200

    @IBOutlet weak var plantTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        plantTableView.dataSource = self
        plantTableView.delegate = self
        title = Constants.appName
        
        plantTableView.register(UINib(nibName: Constants.Identifier.plantTableViewCellNib, bundle: nil), forCellReuseIdentifier: Constants.Identifier.plantTableViewCell)
        
        loadPlant()
    }
    
    func loadPlant() {
        plant.append(Plant(name: "Plant A", location: "Home", image: "pa"))
        plant.append(Plant(name: "Plant B", location: "Home", image: "pb"))
        plant.append(Plant(name: "Plant C", location: "Office", image: "pc"))
    }
    @IBAction func logoutPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.plantTableViewCell, for: indexPath) as! PlantTableViewCell
        cell.plantName.text = plant[indexPath.section].name
        cell.plantLocation.text = plant[indexPath.section].location
        cell.plantImage.image = UIImage(named: plant[indexPath.section].image!)
        return cell
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
}
