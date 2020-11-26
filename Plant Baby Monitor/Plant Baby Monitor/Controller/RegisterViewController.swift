//
//  RegisterViewController.swift
//  Plant Baby Monitor
//
//  Created by Farhad Ullah Rezwan on 20/10/20.
//

import UIKit
import Firebase
import FacebookLogin
import TinyConstraints
import NVActivityIndicatorView

class RegisterViewController: UIViewController {

    weak var databaseController: DatabaseProtocol?
    var activityIndicator: NVActivityIndicatorView?
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
        
        setupActivityIndicator()
    }

    /// Function to help decorate buttons for the current view controller
    private func decorateUIButtons() {
        /// Make the button round with
        registerUIButton.layer.cornerRadius = 40
        registerUIButton.layer.cornerRadius = 40
        
        
        /// generating login button for Facebook
        let loginButton = FBLoginButton()
        loginButton.center = view.center
        loginButton.delegate = self
        
        /// adding login button in the view
        self.view.addSubview(loginButton)
        
        /// adding constraints with tinyconstraints library
        loginButton.top(to: registerUIButton, offset: 100)
        loginButton.centerX(to: view)
    }
    
    // Activity indicator view setup at the middle of the screen
    private func setupActivityIndicator() {
        // indicator for loading the weather
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame,type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator?.backgroundColor = UIColor.black
        guard let activityIndicator = activityIndicator else {return}
        view.addSubview(activityIndicator)
    }
    
    // Once the user is properly registers for the app, the segue is performed
    @IBAction func registerButtonPressed(_ sender: Any) {
        activityIndicator?.startAnimating()
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    print(err)
                    self.activityIndicator?.stopAnimating()
                    self.displayMessage(title: "User Registration Failure", message: err.localizedDescription)
                } else {
                    self.userID = authResult?.user.uid
                    self.addUserInFirestore()
                    self.finishLogginIn()
                }
            }
        }
    }
    
    /// Adds user in the firestore collection user
    func addUserInFirestore() {
        let _ = databaseController?.addUser(userID: userID!)
    }
    
    func finishLogginIn() {
        activityIndicator?.stopAnimating()
        /// keep the logged in status in
        UserDefaults.standard.setIsLoggedIn(value: true)
        UserDefaults.standard.setUserId(userID: userID ?? " ")
        
        self.performSegue(withIdentifier: K.Segue.registerToHomeSegue, sender: self)
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

// Extension of the LoginViewController Class for LoginButtonDelegate
extension RegisterViewController: LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        print("USer logged in")
        guard let tok = result?.token else {
            return
        }
        firebaseFacebookLogin(accessTocken: (tok.tokenString))
        activityIndicator?.startAnimating()
    }
    

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("User logged out")
    }
    
    
}
