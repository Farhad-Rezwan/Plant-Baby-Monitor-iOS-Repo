//
//  AboutPageViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 25/11/20.
//

import UIKit

// about page of the app
class AboutPageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// simple dismiss of the view button action
    @IBAction func dismissAboutPageButtonClicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
