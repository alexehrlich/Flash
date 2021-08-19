//
//  User.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import Foundation

struct User: Hashable {

    var chatname = String()
    var email = String()
    var chats = [Chat]()
    
    var chatPartnerNamesDictioanry = [String : String]()
    
    //Singleton
    static var shared = User()
    
    mutating func enableUser(chatname: String, email: String){
        self.chatname = chatname
        self.email = email
    }
    
   init(chatname: String, email: String){
        self.chatname = chatname
        self.email = email
    }
    
    init(){

    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
    
    func getChatIDs()-> [String]{
        var temp = [String]()
        for chat in chats{
            temp.append(chat.id)
        }
        return temp
    }
    
    func getChatPartnerMails()-> [String]{
        var temp = [String]()
        for chat in chats{
            temp.append(chat.partnerMail)
        }
        return temp
    }
    
    func getChatPartnerNames()-> [String]{
        var temp = [String]()
        for chat in chats{
            temp.append(chat.partnerName)
        }
        return temp
    }
    
    mutating func removeChat(for id: String){
        
        for i in 0..<chats.count{
            
            if chats[i].id == id{
                chats.remove(at: i)
                break
            }
        }
    }
}

struct Chat: Hashable{
    var partnerMail: String
    var partnerName: String
    var id: String
}

