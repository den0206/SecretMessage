//
//  CommonFB.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import Foundation


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
