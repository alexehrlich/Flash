//
//  ChatListViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit
import Firebase

class ChatListViewController: UIViewController, UIGestureRecognizerDelegate {

    //MARK: - IBOutlets
    @IBOutlet weak var chatListCollectionView: UICollectionView!
    @IBOutlet weak var searchBackground: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    
    //CollectionView Setup
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    
    
    //State Variables
    var tappedCellIndex = 0
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor(named: "TitleColorBlue")
        navigationItem.hidesBackButton = true
        
        setUpCollectionView()
        
        searchBackground.layer.cornerRadius = searchBackground.frame.height * 0.2
        
        searchTextField.attributedPlaceholder = NSAttributedString(string: "Suche", attributes: [.font : UIFont(name: "Helvetica Neue", size: 20)!, .foregroundColor : UIColor.lightGray])

        
    }
    
    private func setUpCollectionView(){
        chatListCollectionView.delegate = self
        chatListCollectionView.dataSource = self
        chatListCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "chatContactCell")
//        let refreshControl = UIRefreshControl()
//        chatListCollectionView.addSubview(refreshControl)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ListToChat"{
            
            if let destVC = segue.destination as? ChatViewController{
                destVC.title = User.shared.chatPartners![tappedCellIndex].getChatName()
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
            //Suche den Nutzer und erstelle den Chat
            if let emailString = createAlert.textFields?.first?.text, emailString != ""{
                self.db.collection("users").document(emailString).getDocument { document, error in
                    
                    if let document = document, document.exists{
                        //
                    }else{
                        print("User does not exist")
                    }
                }
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
        
        if User.shared.chatPartners == nil {
            return 0
        }else{
            return User.shared.chatPartners!.count
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = chatListCollectionView.dequeueReusableCell(withReuseIdentifier: "chatContactCell", for: indexPath) as? ContactCollectionViewCell{
            
            if let chatPartner = User.shared.chatPartners?[indexPath.row]{
                cell.chatNameLabel.text = chatPartner.getChatName()
            }
            
            if let profileImageData = User.shared.getProfileImage(), let profileImage = UIImage(data: profileImageData){
                cell.contactProfileImage.image = profileImage
            }
            
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
