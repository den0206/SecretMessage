//
//  DetailUserViewModel.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import Combine
import Foundation

final class DetailUserViewModel : ObservableObject {
    
    var user : FBUser
    
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
   
}
