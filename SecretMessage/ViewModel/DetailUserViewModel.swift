//
//  DetailUserViewModel.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import SwiftUI
import Foundation

final class DetailUserViewModel : ObservableObject {
    
    @Published var user : FBUser
    @Published var buttonEnable : Bool = false
    
    init(user : FBUser) {
        self.user = user
    }
    
    func startPrivateChat(userInfo : UserInfo) {
        guard !user.isCurrentUser else {return}
        
        let currentUID = userInfo.user.uid
        let user2Id = user.uid
        
        createPrivateChat(currentUID: currentUID, user2ID: user2Id, users: [userInfo.user, user]) { (chatRoomId) in
            
            userInfo.pushMessageView(chatRoomId: chatRoomId, withUser: self.user)
        }
    }
    
    
    func checkFriend(userInfo : UserInfo) {
        guard !user.isCurrentUser else {return}
        let currentUser = userInfo.user

        FBCommon.checkFriend(currentUser: currentUser, withUser: user) { (isFriend) in
            
            self.user.isFriend = isFriend
            
            withAnimation(.easeInOut(duration: 0.7)) {
                self.buttonEnable = true
            }
        }
    }
    func addFriend(userInfo : UserInfo) {
        guard !user.isCurrentUser else {return}
        
        let currentUser = userInfo.user
        
        switch user.isFriend {
        
        case false:
            FBCommon.addFriend(currentUser: currentUser, withUser: user) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
        
                self.user.isFriend = true
                
            }
        case true:
            FBCommon.removeFriend(currentUser: currentUser, withUser: user) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
        
                self.user.isFriend = false
                
            }
        }
        
        
        
    }
   
}
