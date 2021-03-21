//
//  UserInfo.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI
import FirebaseAuth

final class UserInfo : ObservableObject {
    
    enum AuthState {
        case undefined,signOut,signIn
    }
    
    
    
    @Published var isUserAuthenticated : AuthState = .undefined
    @Published var listnerHandle : AuthStateDidChangeListenerHandle?
    @Published var user : FBUser = .init(uid : "", name : "", email : "", fcmToken: "", searchId: "")
    
    @Published var selectMenuIndex = 0
    @Published var showMenu = true
    
    @Published var MSGPushNav = false
    @Published var chatRoomId = ""
    @Published var withUser : FBUser = .init(uid : "", name : "", email : "", fcmToken: "", searchId: "")
    
    func configureStateDidchange() {
        
        listnerHandle = Auth.auth().addStateDidChangeListener({ (_, user) in
            
            guard let user = user else {
                self.isUserAuthenticated = .signOut
                return
            }
            
            FBCommon.fetchUser(uid: user.uid) { (result) in
                switch result {
                
                case .success(let user):
                    self.user = user
                    self.isUserAuthenticated = .signIn
                case .failure(let error):
                    print(error.localizedDescription)
                    self.isUserAuthenticated = .signOut
                }
            }
            
            
        })
        
    }
    
    func pushMessageView(chatRoomId : String, withUser : FBUser) {
    
        self.chatRoomId = chatRoomId
        self.withUser = withUser
        
        self.selectMenuIndex = 0
        self.MSGPushNav = true
    }
}
