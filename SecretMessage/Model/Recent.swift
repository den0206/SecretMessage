//
//  Recent.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import Foundation
import SwiftUI
import Firebase

struct  Recent : Identifiable {
    
    typealias RecentDic = [String : Any]
    
    var id : String
    var userId : String
    var withUserId : String
    var chatRoomId : String
    var lastMessage : String
    var counter : Int
    var date : Timestamp
    
    var withUser : FBUser!
    
    var tmString : String {
        return timeElapsed(date: date.dateValue())
    }
    
    init(dic : RecentDic) {
        self.id = dic[RecentKey.recentID] as? String ?? ""
        self.userId = dic[RecentKey.userId] as? String ?? ""
        self.chatRoomId = dic[RecentKey.chatRoomId] as? String ?? ""
        self.withUserId = dic[RecentKey.withUserId] as? String ?? ""
        self.lastMessage = dic[RecentKey.lastMessage] as? String ?? ""
        self.counter = dic[RecentKey.counter] as? Int ?? 0
        self.date = dic[RecentKey.date] as? Timestamp ?? Timestamp(date: Date())
    }
}


func createPrivateChat(currentUID : String, user2ID : String,users : [FBUser],completion : @escaping(String) -> Void) {
    
    var chatRoomId : String
    
    let value = currentUID.compare(user2ID).rawValue
    
    if value < 0 {
        chatRoomId = currentUID + user2ID
    } else {
        chatRoomId = user2ID + currentUID
    }
    
    let userIds = [currentUID, user2ID]
    var tempMembers = userIds
    
    FirebaseReference(.Recent).whereField(RecentKey.chatRoomId, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else {return}
        
        if !snapshot.isEmpty {
            
            for recent in snapshot.documents {
                let currentRecent = recent.data()
                
                if let currentUserId = currentRecent[RecentKey.userId] {
                    if userIds.contains(currentUserId as! String) {
                        tempMembers.remove(at: tempMembers.firstIndex(of: currentUserId as! String)!)
                    }
                }
            }
        }
        
        tempMembers.forEach { (uid) in
            createRecentFirestore(uid: uid, currentUID: currentUID, chatRoomId: chatRoomId, users: users)
        }
        completion(chatRoomId)
    }
    
}


func createRecentFirestore(uid : String, currentUID : String, chatRoomId : String, users : [FBUser]) {
    
    let ref = FirebaseReference(.Recent).document()
    let recentID = ref.documentID
    
    let withUser : FBUser = uid == currentUID ? users.last! : users.first!
    
    let recent = [RecentKey.recentID : recentID,
                  RecentKey.userId : uid,
                  RecentKey.chatRoomId : chatRoomId,
                  RecentKey.withUserId : withUser.uid,
                  RecentKey.lastMessage : "",
                  RecentKey.counter : 0,
                  RecentKey.date : Timestamp(date: Date())] as [String : Any]
    
    ref.setData(recent)
}
