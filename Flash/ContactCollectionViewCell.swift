//
//  ContactCollectionViewCell.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit

class ContactCollectionViewCell: UICollectionViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var contactProfileImage: UIImageView!
    @IBOutlet weak var chatNameLabel: UILabel!
    @IBOutlet weak var newMessageDot: UIView!
    
    
    var chatID = NSAttributedString()
    var chatPartnerMail = String()
    var chatPartnerName = String()
    var hasNewMessage = false {
        didSet{
            if hasNewMessage == true{
                newMessageDot.isHidden = false
            }else{
                newMessageDot.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setupUI(){
        newMessageDot.layer.cornerRadius = newMessageDot.frame.size.width / 2
        
        let imageHeight = contactProfileImage.frame.size.height
        cellBackgroundView.layer.cornerRadius = cellBackgroundView.frame.height * 0.08
        contactProfileImage.layer.cornerRadius = imageHeight / 2
    }

}
