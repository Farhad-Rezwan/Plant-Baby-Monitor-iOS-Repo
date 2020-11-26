//
//  HomeViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit
import TinyConstraints
import FirebaseAuth
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import NVActivityIndicatorView



class HomeViewController: UIViewController, DatabaseListener {
    

    @IBOutlet weak var plantTableView: UITableView!
    @IBOutlet weak var addPlantUIButton: UIButton!
    var activityIndicator: NVActivityIndicatorView?
    weak var databaseController: DatabaseProtocol?
    var uID: String?
    var listenerType: ListenerType = .user
    var plants: [Plant] = []
    var cellSpacingHeight = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // adding table view delegates
        plantTableView.dataSource = self
        plantTableView.delegate = self

        /// registeres the custom plat cell
        plantTableView.register(UINib(nibName: K.Identifier.plantTableViewCellNib, bundle: nil), forCellReuseIdentifier: K.Identifier.plantTableViewCell)
        
        /// assigns the database delegate
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        /// hiding the back button
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        /// helps to decorate buttons when the view did load
        decorateUIButtons()
        /// activitty indicator setup
        setupActivityIndicator()
    }
    
    /// Function to help decorate buttons for the current view controller
    private func decorateUIButtons() {
        /// designing the plant add to make sure it is consistent in the viewcontroller (adding border)
        addPlantUIButton.layer.borderColor = UIColor.black.cgColor
        addPlantUIButton.layer.borderWidth = 1
        
        /// Make the button round with
        addPlantUIButton.layer.cornerRadius = 40
        

    }
    
    /// Activity indicator view setup at the middle of the screen
    private func setupActivityIndicator() {
        // indicator for loading the weather
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame,type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator?.backgroundColor = UIColor.black
        guard let activityIndicator = activityIndicator else {return}
        view.addSubview(activityIndicator)
    }

    /// once the logout button is pressed the user is navigated to the root view controller
    @IBAction func logoutPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Logout?", message: "Do you want to logout", preferredStyle: .alert)
        let yes = UIAlertAction(title: "YES", style: .default) { (action) in
            
            self.activityIndicator?.startAnimating()
            /// perform logo0ut opration
            self.performLogoutOperation()
        }
        let no = UIAlertAction(title: "NO", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(yes)
        alert.addAction(no)
        present(alert, animated: true, completion: nil)

    }
    
    private func performLogoutOperation(){
        UserDefaults.standard.setIsLoggedIn(value: false)
        UserDefaults.standard.setUserId(userID: " ")
        
        guard Auth.auth().currentUser != nil else { return
        }
        if let accessTocken = AccessToken.current {
            // user is already loggind in with facebook
            print("user is already logged in")
            print(accessTocken)
            LoginManager().logOut()
        }
        
        do {
            try Auth.auth().signOut()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        handleViewControllerArraysForNavigationController()
    }
    
    /// Makes sure when the user logged out is performed the new view controller stack is loaded in the navigation controller
    private func handleViewControllerArraysForNavigationController() {
        self.activityIndicator?.stopAnimating()
        guard let navigationController = self.navigationController else { return }
        
        /// removing the previous view controller
        var navigationArray = navigationController.viewControllers // To get all UIViewController stack as Array
        navigationArray.removeAll() // To remove previous UIViewController
        
        /// intanstiate new stack
        let viewControllers = storyboard?.instantiateViewController(identifier: K.Identifier.welcomeViewController) as! WelcomeViewController
        /// attach the new stack in the navigaiton controller
        navigationController.viewControllers = [viewControllers]
        navigationController.popToRootViewController(animated: true)
    }
    
    /// adds the users listener when the view is loaded
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let userID = uID else {return}
        databaseController?.addListener(listener: self, userCredentials: userID, plantID: " ")
        plantTableView.reloadData()
    }
    
    /// removes the user's listener when the view is no longer visable
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func addPlantButtonPressed(_ sender: Any) {
        let viewController = storyboard?.instantiateViewController(identifier: K.Identifier.addPlantViewController) as! AddPlantViewController
        viewController.userDocumentID = uID
        viewController.delegateForEdit = self
        self.present(viewController, animated: true, completion: nil)
    }
    
    

    // MARK:- Listener Methods
    func onUserChange(change: DatabaseChange, userPlants: [Plant]) {
        print("User listener listening")
        plants = userPlants
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
        return plants.count
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
        cell.plantName.text = plants[indexPath.section].name
        cell.plantLocation.text = plants[indexPath.section].location
        cell.plantImage.image = UIImage(named: plants[indexPath.section].image)
        
        /// reference: https://stackoverflow.com/questions/34778283/what-is-the-action-for-custom-accessory-view-button-swift
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "plantEditButtonCell"), for: .normal)
        button.addTarget(self, action: #selector(self.editPlantButtonPressed), for: .touchUpInside)
        button.tag = indexPath.section
        cell.addSubview(button)
        
        /// making the button center to the super view in the right side
        button.rightToSuperview()
        button.centerYToSuperview()
        
        return cell
    }
    
    @objc func editPlantButtonPressed(sender : UIButton) {
        print(sender.tag)
        print("pressed")
                    //Write button action here
        let viewController = storyboard?.instantiateViewController(identifier: K.Identifier.editPlantViewController) as! EditPlantViewController
        viewController.uID = uID
        viewController.plant = plants[sender.tag]
        viewController.delegateForEdit = self
        // navigationController?.pushViewController(viewController, animated: true)
        self.present(viewController, animated: true, completion: nil)
    }
    
    /// navigate to chars view when any of the plat is selected - Should show plant information
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewController = storyboard?.instantiateViewController(identifier: K.Identifier.plantChartDetailsViewController) as! ChartsViewController
        
        viewController.plant = plants[indexPath.section]
        viewController.uID = uID
        navigationController?.pushViewController(viewController, animated: true)
        
    }
}

extension HomeViewController: ReloadDataAfterEdit {
    func didFinishEditing() {
        plantTableView.reloadData()
    }
}

