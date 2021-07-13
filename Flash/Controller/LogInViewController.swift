//
//  LogInViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Easy log in
        emailTextField.text = "a@b.com"
        passwordTextField.text = "123456"
        
        UISetUp()
    }
    
    //MARK: - IBActions
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        
        spinner.startAnimating()
        self.logInButton.titleLabel?.text = ""
        
        if let emailString = emailTextField.text, let passwordString = passwordTextField.text {
            
            Auth.auth().signIn(withEmail: emailString, password: passwordString) { result, error in
                
                self.spinner.stopAnimating()
                self.logInButton.titleLabel?.text = "Log In"
                
                if error != nil {
                    let alert = UIAlertController(title: "Oops :-(", message: error?.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    let segueAction = UIAlertAction(title: "Create user", style: .default) { action in
                        self.performSegue(withIdentifier: "logInToRegister", sender: self)
                    }
                    alert.addAction(okayAction)
                    alert.addAction(segueAction)
                    self.present(alert, animated: true, completion: nil)
                    print(error!.localizedDescription)
                }else{
                    User.shared.email = emailString
                    self.performSegue(withIdentifier: "logInToChatList", sender: self)
                }
            }
        }
    }
    
    
    private func UISetUp(){
        navigationController?.navigationBar.tintColor = UIColor(named: "TitleColorBlue")
        logInButton.layer.cornerRadius = 5
        
    }
}
