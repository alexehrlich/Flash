//
//  RegisterViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit

class RegisterViewController: UIViewController {
    
    //MARK: - IBOutlets:
    
    @IBOutlet weak var chatnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISetup()

    }
    


    private func UISetup(){
        
        signUpButton.layer.cornerRadius = 5
    }

}
