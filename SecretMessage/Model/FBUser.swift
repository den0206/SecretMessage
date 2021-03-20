//
//  FBUser.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import Foundation

struct FBUser {
    
    typealias UserDic = [String : Any]
    
    let uid : String
    var name : String
    var email : String
    var fcmToken : String
    var searchId : String
    
    var avatarUrl : URL?
    
    init(uid : String,name : String,email : String,fcmToken : String,searchId : String) {
        
        self.uid = uid
        self.name = name
        self.email = email
        self.fcmToken = fcmToken
        self.searchId = searchId
        
    }
    
    init?(dic : UserDic) {
        
        let uid = dic[Userkey.userID] as? String ?? ""
        let name = dic[Userkey.name] as? String ?? ""
        let email = dic[Userkey.email] as? String ?? ""
        let fcmToken = dic[Userkey.fcmToken] as? String ?? ""
        let searchId = dic[Userkey.searchID] as? String ?? ""
        
        self.init(uid: uid, name: name, email: email,fcmToken : fcmToken,searchId : searchId)
        
        if let urlString = dic[Userkey.avatarUrl] as? String {
            self.avatarUrl = URL(string: urlString)
        }
    }
}
