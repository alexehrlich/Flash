//
//  PageTwoView.swift
//  Flash
//
//  Created by Alexander Ehrlich on 21.07.21.
//

import UIKit

class PageTwoView: UIView {

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
    }
}
