//
//  RegisterViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    //MARK: - IBOutlets:
    
    @IBOutlet weak var chatnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UISetup()
    }
    
    //MARK: - IBActions
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        spinner.startAnimating()
        signUpButton.setTitle("", for: .normal)
        
        if let emailString = emailTextField.text, let chatname = chatnameTextField.text, let passwordString = passwordTextField.text{
            
            DispatchQueue.global(qos: .userInitiated).async {
                Auth.auth().createUser(withEmail: emailString, password: passwordString) { result, error in
                    
                    self.spinner.stopAnimating()
                    self.signUpButton.setTitle("Sign me up!", for: .normal)
                    
                    if let error = error {
                        
                        let alert = UIAlertController(title: "Oops :-(", message: error.localizedDescription, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated: true, completion: nil)
                        print(error.localizedDescription)
                    }else{
                        User.shared.email = emailString
                        User.shared.enableUser(chatname: chatname, email: emailString)
                        self.performSegue(withIdentifier: "registerToChatList", sender: self)
                    }
                }
            }
            
            
            //look, if user already exists
            DispatchQueue.global(qos: .userInitiated).async {
                self.db.collection("users").document(emailString).getDocument { document, error in
                    if let receivedDoc = document{
                        if !receivedDoc.exists{
                            //Create new user
                            print("User does not exsist and will be created.")
                            self.db.collection(K.Firestore.userCollection).document(emailString).setData([K.Firestore.chatNameField: chatname, K.Firestore.chatPartnersMailField : [String](), K.Firestore.chatPartnersNameField: [String]() ,K.Firestore.chatIDsField : [String](), K.Firestore.unansweredChatsField : [String]()]) { error in
                                if let e = error {
                                    print("Something went wrong, \(e)")
                                }else{
                                    print("Data saved successfully")
                                }
                            }
                        }else{
                            print("User already exists.")
                        }
                    }
                }
            }
        }
    }
    
    
    private func UISetup(){
        navigationController?.navigationBar.tintColor = UIColor(named: "TitleColorBlue")
        signUpButton.layer.cornerRadius = 5
    }
    
}
