//
//  ChatListViewController.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import UIKit

class ChatListViewController: UIViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var chatListCollectionView: UICollectionView!
    
    //CollectionView Setup
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpCollectionView()

        
    }
    
    private func setUpCollectionView(){
        

        
        chatListCollectionView.delegate = self
        chatListCollectionView.dataSource = self
        chatListCollectionView.register(UINib(nibName: "ContactCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "chatContactCell")
        
//        let refreshControl = UIRefreshControl()
//        chatListCollectionView.addSubview(refreshControl)
    }

}

//MARK: - UICollectionView Delegates
extension ChatListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = chatListCollectionView.dequeueReusableCell(withReuseIdentifier: "chatContactCell", for: indexPath) as? ContactCollectionViewCell{
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
    
    
    
}
