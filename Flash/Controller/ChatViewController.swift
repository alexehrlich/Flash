//
//  ChatViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 10.07.21.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var textFieldBackground: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var sendButtonView: UIView!
    
    //MARK: - NSLayoutContraints
    @IBOutlet weak var bottomViewBottomConstraint: NSLayoutConstraint!
    
    var messages = [Message]()
    
    var chatPartner = String()
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        bottomView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        
        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "MessageCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillshowAction), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHideAction), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        textFieldBackground.layer.cornerRadius = 10
    }
    
    @objc func keyboardWillshowAction(notification: NSNotification){
        if let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            
            bottomViewBottomConstraint.constant = frame.size.height
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc func keyBoardWillHideAction(notification: NSNotification){
            bottomViewBottomConstraint.constant = 0

            UIView.animate(withDuration: 0.1) {
                self.view.layoutIfNeeded()
            }
    }
    
    @objc func hideKeyboard(){
        messageTextField.resignFirstResponder()
    }
    
    private func animateSendButton(){
        
        UIView.animate(withDuration: 0.1) {
            self.sendButtonView.transform = CGAffineTransform.identity.scaledBy(x: 0.85, y: 0.85)
        } completion: { _ in
            self.sendButtonView.transform = CGAffineTransform.identity
        }

    }
    
    //MARK: - IBActions
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        animateSendButton()
        //1. Add message to Chat
        
        if let messageBody = messageTextField.text{
            
            let newMessage = db.collection(User.shared.email + chatPartner).document()
            
            newMessage.setData(["sender" : User.shared.email, "body" : messageBody]) { error in
                if let e = error {
                    print("Message could not be saved successfully, \(e)")
                }else{
                    print("Message saved successfully")
                }
            }
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let messageCell = messageTableView.dequeueReusableCell(withIdentifier: "MessageCell")  as? MessageCell{
            
            let message = messages[indexPath.row]
            
            if message.sender == User.shared {
                messageCell.leftSpacer.isHidden = false
                messageCell.rightSpacer.isHidden = true
                messageCell.labelView.backgroundColor = UIColor(named: "TitleColorBlue")
                messageCell.messageLabel.textColor = UIColor(named: "LightGreen")
            }else{
                messageCell.leftSpacer.isHidden = true
                messageCell.rightSpacer.isHidden = false
                messageCell.labelView.backgroundColor = UIColor(named: "LightGreen")
                messageCell.messageLabel.textColor = UIColor(named: "TitleColorBlue")
            }
            
            messageCell.messageLabel.text = message.body
            
            return messageCell
        }
        
        return UITableViewCell()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        messageTextField.resignFirstResponder()
    }
}

