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
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    
    //CollectionView Setup
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    
    var filteredChats = User.shared.chats {
        didSet{
            if filteredChats.isEmpty{
                userPromptView.isHidden = false
            }else{
                userPromptView.isHidden = true
            }
        }
    }
    
    var userPromptView = UIView()
    
    //State Variables
    var tappedCellIndex = 0

    
    let db = Firestore.firestore()
    
    var deleteView : DeleteImageView?
    var currentlyDraggedCell : ContactCollectionViewCell?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        userPromptView = createUserPrompt()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        deleteView = DeleteImageView(frame: CGRect(origin: CGPoint(x: self.view.center.x - 50, y: self.view.frame.size.height - 120), size: CGSize(width: 100, height: 100)))
        deleteView!.image = UIImage(systemName: "trash.circle.fill")
        deleteView?.tintColor = UIColor(named: "TitleColorBlue")
        deleteView!.contentMode = .scaleAspectFit
        deleteView?.isUserInteractionEnabled = true
        self.view.addSubview(deleteView!)
        deleteView?.isHidden = true
        deleteView?.alpha = 0
        deleteView?.delegate = self
        
        navigationController?.navigationBar.tintColor = UIColor(named: "TitleColorBlue")
        navigationItem.hidesBackButton = true
        
        //Setup collectionView
        chatListCollectionView.delegate = self
        chatListCollectionView.dataSource = self
        chatListCollectionView.dragDelegate = self

        chatListCollectionView.dragInteractionEnabled = true
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
                                    
                                    //Add SnapshotListener to the newChat
                                    self.db.collection(K.Firestore.chatIDCollection).document(chatID).addSnapshotListener { snapshot, error in
                                        
                                        if let snapshot = snapshot{
                                            
                                            if let deleted = snapshot.data()?[K.Firestore.isDeletedField] as? Bool {
                                                if deleted == true {
                                                    self.deleteUser(with: chatID){
                                                        //Delete Chat in DB
                                                        self.db.collection(K.Firestore.chatIDCollection).document(chatID).delete()
                                                    }
                                                }
                                            }else{
                                                //This must be a new Message
                                                
                                            }
                                        }
                                    }
                                    
                                    
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
            self.updateModelfromFirebaseDataBase()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //When we come from the chat
        updateModelfromFirebaseDataBase()
    }
    
    private func createUserPrompt() -> UIView{
        
        let label = UILabel()
        label.text = "Du hast noch keine Chats. Tippe oben liks auf den Stift um einen neuen Chat zu erstellen."
        label.font = UIFont(name: "Helvetica Neue", size: 20)
        label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.numberOfLines = 0
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "square.and.pencil")
        imageView.tintColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [label, imageView])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.layer.cornerRadius = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(stackView)
        
        let horizontalConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let verticalConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let widthConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.6, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: stackView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.width, multiplier: 0.6, constant: 0)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        
        stackView.isHidden = true
        
        return stackView
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
                                newChat.setData([K.Firestore.senderMailField : User.shared.email, K.Firestore.senderNameField : User.shared.chatname, K.Firestore.requestedUserMailField : requestedPersonMailString, K.Firestore.requestedUserNameField : chatName, K.Firestore.messageIDsField : [String](), K.Firestore.isDeletedField : false])
                                
                                
                                //Add SnapshotListener to the newChat
                                self.db.collection(K.Firestore.chatIDCollection).document(newChatID).addSnapshotListener { snapshot, error in
                                    
                                    if let snapshot = snapshot{
                                        
                                        if let deleted = snapshot.data()?[K.Firestore.isDeletedField] as? Bool {
                                            if deleted == true {
                                                deleteUser(with: newChatID, completion: nil)
                                            }
                                        }
                                    }
                                }
                                
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
            
            cell.chatID = NSAttributedString(string: filteredChats[indexPath.row].id)
            cell.chatNameLabel.text = filteredChats[indexPath.row].partnerName
            cell.hasNewMessage = false
            cell.setupUI()
            
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

//MARK: -UICollectionViewDragDelegate

extension ChatListViewController: UICollectionViewDragDelegate{
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        collectionViewBottomConstraint.constant = 100
        currentlyDraggedCell = chatListCollectionView.cellForItem(at: indexPath) as? ContactCollectionViewCell

            UIView.animate(withDuration: 0.3) {
                self.currentlyDraggedCell?.transform = CGAffineTransform.identity.scaledBy(x: 0.4, y: 0.4)
                self.deleteView?.isHidden = false
                self.deleteView?.alpha = 1
                self.view.layoutIfNeeded()
            }
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem]{
        if let id = (chatListCollectionView.cellForItem(at: indexPath) as? ContactCollectionViewCell)?.chatID{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: id))
            dragItem.localObject = id
            return  [dragItem]
        }
        return []
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        UIView.animate(withDuration: 0.3) {
            self.currentlyDraggedCell?.transform = CGAffineTransform.identity
            self.deleteView?.isHidden = true
            self.deleteView?.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatListViewController: DeleteImageViewDropDelegate{
    
    func deleteViewDropInteraction(_ deleteView: DeleteImageView, didReceiveDrop id: NSAttributedString) {
        deleteUser(with: id.string, completion: nil)
        self.collectionViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3) {
            self.deleteView?.isHidden = true
            self.deleteView?.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func deleteViewDropInteraction(_ deleteView: DeleteImageView, didEnterDropZone: Bool) {
        
//        UIView.animate(withDuration: 0.3) {
//            self.currentlyDraggedCell?.transform = CGAffineTransform.identity.scaledBy(x: 0.7, y: 0.7)
//        }
    }
    
    
    private func deleteUser(with id: String, completion: (() -> Void)?){
        
        //Delete chatID-item in chatID-collection
        //The deleting User sets the "isDeletedField" so the Listener at the chat partner gets called
        self.db.collection(K.Firestore.chatIDCollection).document(id).updateData([K.Firestore.isDeletedField : true])
        
        //Delete Chat partner and chatID for this user
        User.shared.removeChat(for: id)
        
        self.db.collection(K.Firestore.userCollection).document(User.shared.email).updateData(
            [
                K.Firestore.chatPartnersMailField : User.shared.getChatPartnerMails(),
                K.Firestore.chatPartnersNameField : User.shared.getChatPartnerNames(),
                K.Firestore.chatIDsField : User.shared.getChatIDs()
            ]) { error in
            
            if let e = error {
                print("Update went wrong: \(e.localizedDescription)")
            }else{
                //The deleted chatPartner calls the compeltion handler in his listener and finally deltes the caht from the db.
                if completion != nil {
                    completion!()
                }
            
                self.updateModelfromFirebaseDataBase()
            }
        }
    }
}



