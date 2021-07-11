//
//  User.swift
//  Flash
//
//  Created by Alexander Ehrlich on 09.07.21.
//

import Foundation

struct User: Hashable {

    private var chatname = String()
    private var email = String()
    private var password = String()
    private var profileImage: Data?
    var chatPartners : [User]?
    
    //Array of unique chat ids
    var chats = [Int]()
    var hasValidFirebaseInstance = false
    private var isSignedIn = false
    
    //Singleton
    static var shared = User()
    
    mutating func enableUser(chatname: String, email: String, password: String){
        self.chatname = chatname
        self.email = email
        self.password = password
        hasValidFirebaseInstance = true
        isSignedIn = true
    }
    
   init(chatname: String, email: String, profileImage: Data?){
        self.chatname = chatname
        self.email = email
        self.profileImage = nil
    }
    
    init(){
        
    }
    
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.getEmail() == rhs.getEmail()
    }
    
    func hash(into hasher: inout Hasher) {
            hasher.combine(email)
        }

    
    func getSignState() -> Bool{
        return isSignedIn
    }
    
    func getChatName() -> String{
        return chatname
    }
    
    func getPassword() -> String{
        return password
    }
    
    func getProfileImage() -> Data?{
        return profileImage
    }
    
    func getEmail() -> String{
        return email
    }
}

