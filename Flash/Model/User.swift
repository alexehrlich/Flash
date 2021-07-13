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
    var chatPartners = [String]()
    var chats = [String]()
    
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
}

