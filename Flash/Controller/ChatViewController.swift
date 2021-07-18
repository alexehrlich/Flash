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
    var chatID = String()
    let db = Firestore.firestore()
    
    override func viewWillAppear(_ animated: Bool) {
        
        //Add snapshotListner
        DispatchQueue.global(qos: .userInitiated).async {
            self.db.collection(self.chatID).order(by: "timeStamp").addSnapshotListener { querySnapshot, error in
                
                self.messages.removeAll()
                
                if let snapshotDocuments = querySnapshot?.documents{
                    
                    for document in snapshotDocuments{
                        if let sender = document.data()["sender"] as? String, let body = document.data()["body"] as? String{
                            self.messages.append(Message(sender: User(chatname: "TODO", email: sender), body: body))
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.messageTableView.reloadData()
                        self.scrollMessageTableViewToBottom()
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextField.delegate = self
        
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
    
    private func scrollMessageTableViewToBottom(){
        if self.messages.count > 0 {
            self.messageTextField.text = ""
            self.messageTableView.scrollToRow(at: IndexPath(row: self.messages.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        animateSendButton()

        if let messageBody = messageTextField.text, messageBody != ""{
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                //Empty the local messages
                var updatedMessages = [String]()
                
                //Create a new Message-Oject
                let newMessage = self.db.collection(self.chatID).document()
                let newMessageID = newMessage.documentID
                
                //Update Data for the new message in firebase
                newMessage.setData(["sender" : User.shared.email, "body" : messageBody, "timeStamp" : Date().timeIntervalSince1970]) { error in
                    if let e = error {
                        print("Message could not be saved successfully, \(e)")
                    }else{
                        print("Message saved successfully")
                    }
                }
                
                //Get the current database Data of the current chat
                self.db.collection("chats").document(self.chatID).getDocument { document, error in
                    
                    if let document = document, document.exists{
                        
                        //Store the current messages Array
                        if let oldMessages = document.data()?["messages"] as? [String]{
                            
                            //Add new generated Messages to the loacal storage (DataBase for table view)
                            updatedMessages = oldMessages + [newMessageID]
                            
                            //Push the local changes to firebase
                            self.db.collection("chats").document(self.chatID).updateData(["messages" : updatedMessages])
                            
                            //Scroll to the bottom of the chat table view
                            DispatchQueue.main.async {
                                self.scrollMessageTableViewToBottom()
                            }
                        }
                    }
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
}

extension ChatViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollMessageTableViewToBottom()
    }
}



