//
//  PageTwoView.swift
//  Flash
//
//  Created by Alexander Ehrlich on 21.07.21.
//

import UIKit

class PageTwoView: UIView {

    @IBOutlet weak var alertView: UIStackView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var cancleButtonView: UILabel!
    @IBOutlet weak var goButtonView: UILabel!
    
    private let mailAdress = Array("example@mail.com")
    
    var animtate = false {
        
        didSet{
            textField.text = ""
            if animtate{
                print(mailAdress)
                let _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                    for i in 0..<self.mailAdress.count{
                        let _ = Timer.scheduledTimer(withTimeInterval: Double(i) * 0.2, repeats: false) { _ in
                            self.textField.text? += String(self.mailAdress[i])
                        }
                    }
                }
            }
        }
    }
    
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.configureView()
    }
    
    private func configureView(){
        guard let view = self.loadViewFromNib(nibname: "PageTwoView") else { return }
        view.frame = self.bounds
        self.addSubview(view)
        
        alertView.layer.cornerRadius = 12
        alertView.layer.borderWidth = 0.5
        alertView.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1).cgColor
        
        goButtonView.layer.masksToBounds = true
        cancleButtonView.layer.masksToBounds = true
        goButtonView.clipsToBounds = true
        cancleButtonView.clipsToBounds = true

      
        textFieldBackground.layer.cornerRadius = 8
        textFieldBackground.layer.borderWidth = 0.5
        textFieldBackground.layer.borderColor = UIColor.lightGray.cgColor
        

    }
}
