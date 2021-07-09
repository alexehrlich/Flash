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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellBackgroundView.layer.cornerRadius = 5
    }

}
