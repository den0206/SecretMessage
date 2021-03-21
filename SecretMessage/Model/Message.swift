//
//  Message.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import Foundation
import Firebase

struct Message : Identifiable, Equatable {
    
    typealias MessageDic = [String : Any]
    
    var id : String
    var userID : String
    var text : String
    var chatRoomId : String
    var date : Timestamp
    
    var read : Bool
    
    var tmString : String {
        return timeElapsed(date: date.dateValue())
    }
    
    init(dic : MessageDic) {
        self.id = dic[MessageKey.messageId] as? String ?? ""
        self.userID = dic[MessageKey.userID] as? String ?? ""
        self.chatRoomId = dic[MessageKey.chatRoomId] as? String ?? ""
        self.date = dic[MessageKey.date] as? Timestamp ?? Timestamp(date: Date())
        
        if let read = dic[MessageKey.read] as? Bool {
            self.read = read
        } else {
            self.read = false
        }
        
        if let baseText = dic[MessageKey.text] as? String {
            self.text
                = Cryptography.shared.decypt(baseText: baseText)
        } else {
            self.text = ""
        }
    }
}
