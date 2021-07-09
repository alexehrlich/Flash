//
//  LogInViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit

class LogInViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        UISetUp()
    }
    

    private func UISetUp(){
        logInButton.layer.cornerRadius = 5
        
    }

}
