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
    @IBOutlet weak var registerUIButton: UIButton!

    var userID: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// adding delegate, because need to update user in the firestore
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        /// helps to decorate buttons when the view did load
        decorateUIButtons()
    }
    
    /// Function to help decorate buttons for the current view controller
    private func decorateUIButtons() {
        /// Make the button round with
        registerUIButton.layer.cornerRadius = 40
        registerUIButton.layer.cornerRadius = 40
    }
    
    // Once the user is properly registers for the app, the segue is performed
    @IBAction func registerButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    print(err)
                    self.displayMessage(title: "User Registration Failure", message: err.localizedDescription)
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
    
    /// Displays Alert for invalid infomation
    /// - Parameters:
    ///   - title: the title of the alert
    ///   - message: message of the allert
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// when user presses anywhere else other than keyboard the keyboard will hide
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

