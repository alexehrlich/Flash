//
//  K.swift
//  Flash
//
//  Created by Alexander Ehrlich on 15.07.21.
//

//This file contians all the String-Constants

struct K{
    
    struct Firestore {
        //Collections
        static let userCollection = "users"
        static let chatIDCollection = "chatIDs"
        
        //User Fields
        static let chatNameField = "chatName"
        static let chatPartnersMailField = "chatPartPartnersMail"
        static let chatPartnersNameField = "chatPartPartnersName"
        static let chatIDsField = "userChatIDs"
        
        //Chat Fields
        static let senderMailField = "senderMail"
        static let senderNameField = "senderName"
        static let requestedUserMailField = "requestedUserMail"
        static let requestedUserNameField = "requestetUserName"
        static let messageIDsField = "messageIDs"
        
        }
}
