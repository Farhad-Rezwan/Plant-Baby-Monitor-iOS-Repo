//
//  WelcomeViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var loginButtonUIButton: UIButton!
    @IBOutlet weak var registerButtonUIButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// helps to decorate buttons when the view did load
        decorateUIButtons()
    }
    
    /// Function to help decorate buttons for the current view controller
    private func decorateUIButtons() {
        /// Make the button round with 
        loginButtonUIButton.layer.cornerRadius = 40
        registerButtonUIButton.layer.cornerRadius = 40
    }
}
