//
//  LoginViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit
import Firebase
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var userID: String?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /// adding delegate, because need to update user in the firestore
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        /// Assigning text field delegate.
        /// Making sure that when user presses return button, or presses anywhere else in the screen  keyboard is hidden
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        /// facebook login things
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        loginButton.delegate = self
        self.view.addSubview(loginButton)
        
        if let accessTocken = AccessToken.current {
            // user is already loggind in with facebook
            print("user is already logged in")
            print(accessTocken)
//            firebaseFacebookLogin(accessTocken: accessTocken.tokenString)
//            loginButton.isHidden = true
        }
    }
    
    // Once the user is properly logged in, the segue is performed
    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    print(err)
                    self.displayMessage(title: "Login Failure", message: err.localizedDescription)
                } else {
                    
                    self.userID = authResult?.user.uid
                    self.finishLogginIn()


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
    
    
    func firebaseFacebookLogin(accessTocken: String) {
        let credential = FacebookAuthProvider.credential(withAccessToken: accessTocken)
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("firebase login error")
                print(error)
                self.displayMessage(title: "Login Failure", message: error.localizedDescription)
                return
            }
            // user has signed in
            print("Firebase login done")
            self.userID = authResult?.user.uid
            if let user = Auth.auth().currentUser {
                print("currrent firebase user is ")
                print(user)
                print(user.uid)
            }
            self.finishLogginIn()
            self.addUserInFirestore()
        }
    }
    
    func finishLogginIn() {
        self.performSegue(withIdentifier: K.Segue.loginToHomeSegue, sender: self)
    }
    
    /// Adds user in the firestore collection user
    func addUserInFirestore() {
        let _ = databaseController?.addUser(userID: userID!)
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

extension LoginViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        print("USer logged in")
        guard let tok = result?.token else {
            return
        }
        firebaseFacebookLogin(accessTocken: (tok.tokenString))
    }
    

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User logged out")
    }
    
    
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// when user presses anywhere else other than keyboard the keyboard will hide
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
