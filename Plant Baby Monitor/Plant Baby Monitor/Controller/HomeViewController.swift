//
//  HomeViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = Constants.appName
    }
    @IBAction func logoutPressed(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}
