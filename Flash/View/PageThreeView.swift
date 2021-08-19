//
//  PageThreeView.swift
//  Flash
//
//  Created by Alexander Ehrlich on 21.07.21.
//

import UIKit

class PageThreeView: UIView {
    
    @IBOutlet weak var messageOne: UIView!
    @IBOutlet weak var messageTwo: UIView!
    @IBOutlet weak var messageThree: UIView!
    @IBOutlet weak var messageFour: UIView!
    
    lazy var messageBubbleArray = [messageOne, messageTwo, messageThree, messageFour]
    
    var animate = false {
        didSet{
            
            hideAllMessages()
            if animate == true{
                UIView.animate(withDuration: 0.3) {
                    self.messageBubbleArray[0]?.isHidden = false
                    self.messageBubbleArray[0]?.layer.cornerRadius = 5
                    self.messageBubbleArray[0]?.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                } completion: { _ in
                    UIView.animate(withDuration: 0.3) {
                        self.messageBubbleArray[0]?.transform = .identity
                        self.messageBubbleArray[1]?.isHidden = false
                        self.messageBubbleArray[1]?.layer.cornerRadius = 5
                        self.messageBubbleArray[1]?.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                    } completion: { _ in
                        UIView.animate(withDuration: 0.3) {
                            self.messageBubbleArray[1]?.transform = .identity
                            self.messageBubbleArray[2]?.isHidden = false
                            self.messageBubbleArray[2]?.layer.cornerRadius = 5
                            self.messageBubbleArray[2]?.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                            
                        } completion: { _ in
                            UIView.animate(withDuration: 0.3) {
                                self.messageBubbleArray[2]?.transform = .identity
                                self.messageBubbleArray[3]?.isHidden = false
                                self.messageBubbleArray[3]?.layer.cornerRadius = 5
                                self.messageBubbleArray[3]?.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
                            }completion: { _ in
                                UIView.animate(withDuration: 0.1) {
                                    self.messageBubbleArray[3]?.transform = .identity
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    override func awakeFromNib() {
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
        guard let view = self.loadViewFromNib(nibname: "PageThreeView") else { return }
        view.frame = self.bounds
        self.addSubview(view)
    }
    
    func hideAllMessages(){
        
        messageBubbleArray.forEach{ $0?.layer.cornerRadius = ($0?.frame.size.width)! * 0.03; $0?.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)}
        messageBubbleArray.forEach({$0?.isHidden = true})
    }
    
    private func bounceView(for index: Int){
        
    }
}
