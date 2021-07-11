//
//  MessageCell.swift
//  Flash
//
//  Created by Alexander Ehrlich on 11.07.21.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var leftSpacer: UIView!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var rightSpacer: UIView!
    @IBOutlet weak var messageStackView: UIStackView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        labelView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
