//
//  LoginViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    var userID: String?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    // Once the user is properly logged in, the segue is performed
    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    print(err)
                } else {
                    
                    self.userID = authResult?.user.uid
                    self.performSegue(withIdentifier: K.Segue.loginToHomeSegue, sender: self)
                    

                }
            }
        }
    }
        
    // prepares userID to be transfered to the HomeViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.loginToHomeSegue {
            let destination = segue.destination as! HomeViewController
            destination.uID = userID
        }
    }

}
