//
//  CustomNavigationController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit

/// Class to make custom back button for the navigation. also hold information of the next to root view controller
class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        /// using default value to make the color navigation title color  failproff
        self.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor(named: K.Colors.buttonTxtColor) ?? UIColor.label,
             NSAttributedString.Key.font: UIFont(name: K.defaultFont, size: 21)!]
        
        /// change root view controller depending on the user login status keept in the User Default
        if UserDefaults.standard.isLoggedIn() {
            let homeViewController = storyboard?.instantiateViewController(identifier: K.Identifier.homeViewController) as! HomeViewController
            homeViewController.uID = UserDefaults.standard.getUserId()
            viewControllers = [homeViewController]
        } else {
            let welcomeViewController = storyboard?.instantiateViewController(identifier: K.Identifier.welcomeViewController) as! WelcomeViewController
            viewControllers = [welcomeViewController]
        }
        
        
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // Empties the back button title
        // Removing "Back" text
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        // assigns the back button custom image
        let backArrowImage = UIImage(named: "backButton")
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        
        // assignes the back button item
        viewController.navigationItem.backBarButtonItem = item
        // Make the navigation bar background clear
        viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        viewController.navigationController?.navigationBar.shadowImage = UIImage()
        viewController.navigationController?.navigationBar.isTranslucent = true
        // using custom back button image
        viewController.navigationController?.navigationBar.backIndicatorImage = renderedImage
        viewController.navigationController?.navigationBar.backIndicatorTransitionMaskImage = renderedImage
    }
}
