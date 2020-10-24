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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return plant.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Identifier.plantTableViewCell, for: indexPath) as! PlantTableViewCell
        cell.plantName.text = plant[indexPath.row].name
        cell.plantLocation.text = plant[indexPath.row].location
        cell.plantImage.image = UIImage(named: plant[indexPath.row].image!)
        return cell
    }
    
    
}

extension HomeViewController: UITableViewDelegate {
    
}
