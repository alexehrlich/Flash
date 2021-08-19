//
//  DeleteView.swift
//  Flash
//
//  Created by Alexander Ehrlich on 08.08.21.
//

import UIKit

protocol DeleteImageViewDropDelegate {
    func deleteViewDropInteraction(_ deleteView: DeleteImageView, didReceiveDrop id: NSAttributedString)
    func deleteViewDropInteraction(_ deleteView: DeleteImageView, didEnterDropZone: Bool)
}

class DeleteImageView: UIImageView, UIDropInteractionDelegate {
    
    var delegate: DeleteImageViewDropDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        addInteraction(UIDropInteraction(delegate: self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        
        if session.canLoadObjects(ofClass: NSAttributedString.self){
            delegate?.deleteViewDropInteraction(self, didEnterDropZone: true)
            return session.canLoadObjects(ofClass: NSAttributedString.self)
        }
        return false
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: .move)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { providers in
            
            if let droppedID = providers.first as? NSAttributedString{
                self.delegate?.deleteViewDropInteraction(self, didReceiveDrop: droppedID)
            }
        }
    }
}








