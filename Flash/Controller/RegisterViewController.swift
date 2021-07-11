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
        signUpButton.titleLabel?.text = ""
       
        if let emailString = emailTextField.text, let passwordString = passwordTextField.text, let chatname = chatnameTextField.text{
            Auth.auth().createUser(withEmail: emailString, password: passwordString) { result, error in
                
                self.spinner.stopAnimating()
                self.signUpButton.titleLabel?.text = "Sign me up!"
                
                if let error = error {
                    
                    let alert = UIAlertController(title: "Oops :-(", message: error.localizedDescription, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                    print(error.localizedDescription)
                }else{
                    User.shared.enableUser(chatname: chatname, email: emailString, password: passwordString)
                    self.performSegue(withIdentifier: "registerToChatList", sender: self)
                }
            }
            
            //Zuordnung Username <-> Mail
//            db.collection("users").addDocument(data: [emailString : ["chatname": [chatname], "pwd": [passwordString], "chatPartners" : [String](), "chats" : [Int]()]]) { error in
//                if let e = error {
//                    print("Something went wrong, \(e)")
//                }else{
//                    print("Data saved successfully")
//                }
//            }
            
            //look, if user already exists
            
            db.collection("users").document(emailString).getDocument { document, error in
                if let receivedDoc = document{
                    if !receivedDoc.exists{
                        //Create new user
                        print("User does not exsist and will be created.")
                        self.db.collection("users").document(emailString).setData(["chatname": [chatname], "pwd": [passwordString], "chatPartners" : [String](), "chats" : [Int]()]) { error in
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
    

    private func UISetup(){
        navigationController?.navigationBar.tintColor = UIColor(named: "TitleColorBlue")
        signUpButton.layer.cornerRadius = 5
        
    }

}
