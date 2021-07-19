//
//  ChatListViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController, UIGestureRecognizerDelegate{
    
    //MARK: - IBOutlets
    @IBOutlet weak var chatListCollectionView: UICollectionView!
    @IBOutlet weak var searchBackground: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    //CollectionView Setup
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    
    var filteredChats = User.shared.chats
    
    //State Variables
    var tappedCellIndex = 0
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor(named: "TitleColorBlue")
        navigationItem.hidesBackButton = true
        
        //Setup collectionView
        chatListCollectionView.delegate = self
        chatListCollectionView.dataSource = self
        chatListCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "chatContactCell")
        
        searchBackground.layer.cornerRadius = searchBackground.frame.height * 0.2
        
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Suche", attributes: [.font : UIFont(name: "Helvetica Neue", size: 20)!, .foregroundColor : UIColor.lightGray])
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        
        //------
        //Initialize the Model
        updateModelfromFirebaseDataBase()
        
        //Add SnapshotListner for chats. Listen to changes of the chats collection
        DispatchQueue.global(qos: .userInitiated).async {
            
            self.db.collection(K.Firestore.chatIDCollection).addSnapshotListener { snapshot, error in
                
                if let e = error{
                    print("Chats could not be loaded, \(e.localizedDescription)")
                }else{
                    
                    if let snapshot = snapshot{
                        for document in snapshot.documents{
                            
                            let chatData = document.data()
                            let chatID = document.documentID
                            
                            //Unpack the received chatData
                            if let requestedPersonMail = chatData[K.Firestore.requestedUserMailField] as? String, let senderMail = chatData[K.Firestore.senderMailField] as? String, let senderName = chatData[K.Firestore.senderNameField] as? String{
                                
                                //If the requested Person is User.shared, the message is detinated to this device
                                //Only update, if chat is not already in list chatPArtners
                                if requestedPersonMail == User.shared.email && !User.shared.chats.contains(where: { chat in
                                    chat.id == chatID
                                }){
                                    
                                    //Update the local model with the new chat
                                    let newChat = Chat(partnerMail: senderMail, partnerName: senderName, id: chatID)
                                    User.shared.chats.append(newChat)
                                    
                                    //Push local changes to firebase DB
                                    self.db.collection(K.Firestore.userCollection).document(User.shared.email).updateData([K.Firestore.chatIDsField : User.shared.getChatIDs(), K.Firestore.chatPartnersMailField : User.shared.getChatPartnerMails(), K.Firestore.chatPartnersNameField : User.shared.getChatPartnerNames()])
                                    
                                    if let lowercasedSearchString = self.searchTextField.text?.lowercased(){
                                        self.filteredChats = User.shared.chats.filter { $0.partnerName.lowercased().hasPrefix(lowercasedSearchString)}
                                    }else if self.searchTextField.text == ""{
                                        self.filteredChats = User.shared.chats
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.chatListCollectionView.reloadData()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //Fetch the data from Firebase for the local entered email adress
    private func updateModelfromFirebaseDataBase(){
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.db.collection(K.Firestore.userCollection).document(User.shared.email).getDocument { [self] document, error in
                if let document = document, document.exists{
                    let data = document.data()
                    
                    if let chatPartnersMail = data?[K.Firestore.chatPartnersMailField] as? [String],  let chatPartnersName = data?[K.Firestore.chatPartnersNameField] as? [String],let chatName = data?[K.Firestore.chatNameField] as? String, let chats = data?[K.Firestore.chatIDsField] as? [String]{
                        
                        User.shared.chats.removeAll()
                        User.shared.chatname = chatName
                        
                        for i in chatPartnersMail.indices{
                            User.shared.chats.append(Chat(partnerMail: chatPartnersMail[i], partnerName: chatPartnersName[i], id: chats[i]))
                        }
                        
                        filteredChats = User.shared.chats
                        
                        DispatchQueue.main.async {
                            self.chatListCollectionView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ListToChat"{
            
            if let destVC = segue.destination as? ChatViewController{
                destVC.title = User.shared.getChatPartnerNames()[tappedCellIndex]
                destVC.chatPartner = User.shared.getChatPartnerMails()[tappedCellIndex]
                destVC.chatID = User.shared.getChatIDs()[tappedCellIndex]
            }
        }
    }
    
    //MARK: - IBActions
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func createNewChatButtonPressed(_ sender: UIBarButtonItem) {
        
        let createAlert = UIAlertController(title: "Wem möchtest du schreiben?", message: nil, preferredStyle: .alert)
        createAlert.addTextField(configurationHandler: nil)
        createAlert.textFields?.first?.placeholder = "Gebe hier die email-Adresse ein"
        let goAction = UIAlertAction(title: "Los", style: .default) { [self] action in
            
            //Search user and create new chat, check that something is entered, the entered User is not himself or the chat is already created with the person.
            if let requestedPersonMailString = createAlert.textFields?.first?.text, requestedPersonMailString != "", requestedPersonMailString != User.shared.email, !User.shared.chats.contains(where: { chat in
                chat.partnerMail == requestedPersonMailString
            }){
                
                DispatchQueue.global(qos: .userInitiated).async {
                    
                    //Get the current data from the entered user
                    self.db.collection(K.Firestore.userCollection).document(requestedPersonMailString).getDocument { document, error in
                        
                        if let document = document, document.exists{
                            
                            //Get the data of the requested user
                            if let chatName = document.data()?[K.Firestore.chatNameField] as? String, let oldChatPartnerMail = document.data()?[K.Firestore.chatPartnersMailField] as? [String], let oldChatPartnersName = document.data()?[K.Firestore.chatPartnersNameField] as? [String], let oldUserChatIDs = document.data()?[K.Firestore.chatIDsField] as? [String]{
                                
                                //create a new chat with a auto-generated ID
                                let newChat = db.collection(K.Firestore.chatIDCollection).document()
                                let newChatID = newChat.documentID
                                
                                //--UPDATE THE REQUESTED USER IN FIREBASE
                                let newChatIDs = oldUserChatIDs + [newChatID]
                                let newChatPartnersMail = oldChatPartnerMail + [User.shared.email]
                                let newChatPartnersName = oldChatPartnersName + [User.shared.chatname]
                                
                                db.collection(K.Firestore.userCollection).document(requestedPersonMailString).updateData([K.Firestore.chatIDsField : newChatIDs, K.Firestore.chatPartnersMailField : newChatPartnersMail, K.Firestore.chatPartnersNameField : newChatPartnersName], completion: nil)
                                
                                
                                
                                //--UPDATE THE REQUESTING PERSON LOCALLY AND IN FIREBASE
                                //Add this ID and the chatPartners Mail to the current users local Model
                                User.shared.chats.append(Chat(partnerMail: requestedPersonMailString, partnerName: chatName, id: newChatID))
                                filteredChats = User.shared.chats
                                
                                //Push the local updated changes to the firebase DB for the current user
                                db.collection(K.Firestore.userCollection).document(User.shared.email).updateData([K.Firestore.chatIDsField : User.shared.getChatIDs(), K.Firestore.chatPartnersMailField : User.shared.getChatPartnerMails(), K.Firestore.chatPartnersNameField : User.shared.getChatPartnerNames()], completion: nil)
                                
                                //--UPDATE THE CHAT IN FIRESTORE
                                newChat.setData([K.Firestore.senderMailField : User.shared.email, K.Firestore.senderNameField : User.shared.chatname, K.Firestore.requestedUserMailField : requestedPersonMailString, K.Firestore.requestedUserNameField : chatName, K.Firestore.messageIDsField : [String]()])
                                
                                DispatchQueue.main.async {
                                    self.chatListCollectionView.reloadData()
                                }
                            }
                        }else{
                            print("User does not exist")
                        }
                    }
                }
            }else{
                print("User is yourself or chat with requested user already exists")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Abbrechen", style: .cancel, handler: nil)
        
        createAlert.addAction(goAction)
        createAlert.addAction(cancelAction)
        
        present(createAlert, animated: true, completion: nil)
    }
    
}

//MARK: - UICollectionView Delegates
extension ChatListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filteredChats.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = chatListCollectionView.dequeueReusableCell(withReuseIdentifier: "chatContactCell", for: indexPath) as? ContactCollectionViewCell{
            
            cell.chatNameLabel.text = filteredChats[indexPath.row].partnerName
            
            return cell
        }
        return UICollectionViewCell()
    }
    
    //determine the size of the cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //empty space at the borders and between the cells
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        
        //pure with of the of all the cells
        let availableWidth = collectionView.frame.width - paddingSpace
        
        //size of one cell
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    
    func collectionView( _ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        tappedCellIndex = indexPath.item
        searchTextField.resignFirstResponder()
        performSegue(withIdentifier: "ListToChat", sender: self)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchTextField.resignFirstResponder()
    }
}

extension ChatListViewController: UITextFieldDelegate{
    
    @objc func textFieldDidChange(){
        if let lowercasedSearchString = searchTextField.text?.lowercased(){
            filteredChats = User.shared.chats.filter { $0.partnerName.lowercased().hasPrefix(lowercasedSearchString)}
        }else if searchTextField.text == ""{
            filteredChats = User.shared.chats
        }
        
        chatListCollectionView.reloadData()
    }
}

