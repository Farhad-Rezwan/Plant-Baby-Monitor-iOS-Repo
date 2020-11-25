//
//  LoginViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit
import Firebase
import FacebookLogin
import TinyConstraints

class LoginViewController: UIViewController {
    
    weak var databaseController: DatabaseProtocol?
    var userID: String?
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginUIButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        /// adding delegate, because need to update user in the firestore
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        /// Assigning text field delegate.
        /// Making sure that when user presses return button, or presses anywhere else in the screen  keyboard is hidden
        emailTextField.delegate = self
        passwordTextField.delegate = self

        decorateUIButtons()
    }

    /// Function to help decorate buttons for the current view controller
    private func decorateUIButtons() {
        /// Make the button round with
        loginUIButton.layer.cornerRadius = 40
        loginUIButton.layer.cornerRadius = 40
        
        /// generating login button for Facebook
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        loginButton.delegate = self
        
        /// adding login button in the view
        self.view.addSubview(loginButton)
        
        /// adding constraints with tinyconstraints library
        loginButton.top(to: loginUIButton, offset: 100)
        loginButton.centerX(to: view)
    }
    
    // Once the user is properly logged in, the segue is performed
    @IBAction func loginButtonPressed(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            
            /// sign in using firebase signer
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
    
    
    private func firebaseFacebookLogin(accessTocken: String) {
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
    
    /// Once the login is finished perform segue
    private func finishLogginIn() {
        self.performSegue(withIdentifier: K.Segue.loginToHomeSegue, sender: self)
        
        /// keep the logged in status in
    }
    
    /// Adds user in the firestore collection user
    private func addUserInFirestore() {
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

// Extension of the LoginViewController Class for LoginButtonDelegate
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

// Extension of the LoginViewController Class for TextFieldDelegate
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
