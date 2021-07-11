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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageHeight = contactProfileImage.frame.size.height
        cellBackgroundView.layer.cornerRadius = cellBackgroundView.frame.height * 0.08
        contactProfileImage.layer.cornerRadius = imageHeight / 2
        
    }

}
