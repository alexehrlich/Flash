//
//  UIViewExtension.swift
//  Flash
//
//  Created by Alexander Ehrlich on 21.07.21.
//

import Foundation
import UIKit

extension UIView{
    
    func loadViewFromNib(nibname: String) -> UIView?{
        
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibname, bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil)[0] as? UIView
    }
    
}
