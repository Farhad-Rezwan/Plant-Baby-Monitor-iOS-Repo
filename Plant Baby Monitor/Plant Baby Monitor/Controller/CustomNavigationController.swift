//
//  CustomNavigationController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit

class CustomNavigationController: UINavigationController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self

    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let item = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
        let backArrowImage = UIImage(named: "backButton")
        let renderedImage = backArrowImage?.withRenderingMode(.alwaysOriginal)
        
        // Removing "Back" text
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