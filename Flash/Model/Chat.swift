//
//  Chat.swift
//  Flash
//
//  Created by Alexander Ehrlich on 10.07.21.
//

import Foundation

struct Chat{
    
    var id = generateID()
    var messages = [Message]()
    
    static private var newID : UInt = 0
    static func generateID() -> UInt{
        defer{
            newID += 1
        }
        return newID
    }
    
    mutating func addMessage(_ message: Message){
        messages.append(message)
    }
}
