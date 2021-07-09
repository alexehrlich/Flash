//
//  ViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 08.07.21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UISetUp()
    }

    private func UISetUp(){
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor(named: "TitleColorBlue")!]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
    }

}

