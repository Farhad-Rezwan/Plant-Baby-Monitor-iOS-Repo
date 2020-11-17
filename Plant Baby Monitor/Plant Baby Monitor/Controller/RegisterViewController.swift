//
//  RegisterViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var userID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// adding delegate, because need to update user in the firestore
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    // Once the user is properly registers for the app, the segue is performed
    @IBAction func registerButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    print(err)
                } else {
                    self.userID = authResult?.user.uid
                    self.addUserInFirestore()
                    self.performSegue(withIdentifier: K.Segue.registerToHomeSegue, sender: self)
                }
            }
        }
    }
    
    /// Adds user in the firestore collection user
    func addUserInFirestore() {
        let _ = databaseController?.addUser(userID: userID!)
    }
    
    // prepares userID to be transfered to the HomeViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.Segue.registerToHomeSegue {
            let destination = segue.destination as! HomeViewController
            destination.uID = userID
        }
    }
}
