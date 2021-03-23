//
//  CommonFB.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import Foundation
import Firebase


struct FBCommon {
    
    static func fetchUser(uid : String, completion :@escaping(Result<FBUser,Error>) -> Void) {
        
        FirebaseReference(.User).document(uid).getDocument { (snapshot, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
           
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noDocumentSNapshot))
                return
            }
            
            guard let data = snapshot.data() else {
                completion(.failure(FirestoreError.noSnapshotData))
                return
            }
            
            guard let user = FBUser(dic: data) else {
                completion(.failure(FirestoreError.noUser))
                return
            }
            
            completion(.success(user))
        }
        
        
    }
    
    static func searchUser(searchId : String, completion : @escaping(Result<FBUser, Error>) -> Void) {
        
        let ref = FirebaseReference(.User).whereField(Userkey.searchID, isEqualTo: searchId)
        
        ref.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noDocumentSNapshot))
                return
            }
            
            guard !snapshot.isEmpty else {completion(.failure(FirestoreError.noFindUser))
                return
            }
            
            
            let data = snapshot.documents[0].data()
            
            guard let user = FBUser(dic: data) else {completion(.failure(FirestoreError.noUser))
                return}
            
            completion(.success(user))
            
        }
    }
    
    
   
}

//MARK: - Follow

extension FBCommon {
    
    static func checkFriend(currentUser : FBUser, withUser : FBUser,completion :@escaping(Bool) -> Void) {
        
        FirebaseReference(.User).document(currentUser.uid).collection(FriendKey.friends).document(withUser.uid).getDocument { (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            snapshot.exists ? completion(true) : completion(false)
        }
    }
    
    static func addFriend(currentUser : FBUser, withUser : FBUser,completion :@escaping(Error?) -> Void) {
        
        let value = [FriendKey.userID : withUser.uid,FriendKey.date : Timestamp(date: Date())] as [String : Any]
        
        FirebaseReference(.User).document(currentUser.uid).collection(FriendKey.friends).document(withUser.uid).setData(value) { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
    
    static func removeFriend(currentUser : FBUser, withUser : FBUser, completion : @escaping(Error?) -> Void) {
        
        FirebaseReference(.User).document(currentUser.uid).collection(FriendKey.friends).document(withUser.uid).delete { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            completion(nil)
        }
    }
    
}
