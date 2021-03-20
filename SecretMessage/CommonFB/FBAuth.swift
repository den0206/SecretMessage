//
//  FBAuth.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import Foundation
import Firebase

struct FBAuth {
    
    static func createUser(email : String , name : String, searchId : String,password : String, imageData : Data, completion : @escaping(Result<FBUser, Error>) -> Void) {
        
        FirebaseReference(.User).whereField(Userkey.searchID, isEqualTo: searchId).getDocuments { (snapshot, error) in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(FirestoreError.noDocumentSNapshot))
                return
            }
            
            /// check exist same name
            guard snapshot.isEmpty else {
                completion(.failure(FirestoreError.duplicateSearchId))
                return
            }
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let resultUser = result?.user else {
                    completion(.failure(FirestoreError.noAuthResult))
                    return
                }
                
                 let uid = resultUser.uid
                
                let filename =  "Avatars/_" + uid + ".jpeg"
                
                saveToFireStorage(data: imageData, fileName: filename) { (result) in
                    
                    switch result {
                    
                    case .success(let imageUrl):
                        /// for now not set token
                        let fcm = Messaging.messaging().fcmToken ?? ""
                        
                        let data = [Userkey.userID : uid,
                                    Userkey.name : name,
                                    Userkey.email : email,
                                    Userkey.avatarUrl : imageUrl,
                                    Userkey.searchID : searchId,
                                    Userkey.fcmToken : fcm]
                        
                        FirebaseReference(.User).document(uid).setData(data) { (error) in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                        }
                        
                        guard let user = FBUser(dic: data) else {return}
                        completion(.success(user))
                        
                    case .failure(let error):
                        completion(.failure(error))
                        return
                    }
                }
          
                
             }
        }
        
    }
    
    static func loginUser(email :String, password : String, completion : @escaping(Result<String, EmailAuthError>) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            var newError : NSError
            
            if let error = error {
                
                print(error.localizedDescription)
                newError = error as NSError
                var emailError : EmailAuthError?
                
                switch newError.code {
                
                case 17009:
                    emailError = .incorrectPassword
                case 17008 :
                    emailError = .invalidEmail
                case 17011 :
                    emailError = .accountDoesnotExist
                default:
                    emailError = .unknownError
                }
                
                completion(.failure(emailError!))
            } else {
                guard let uid = result?.user.uid else {return}
                updateFCMToken(uid: uid)
                completion(.success(uid))
            }
        }
    }
    
    static func updateFCMToken(uid : String) {
        let fcm = Messaging.messaging().fcmToken ?? ""
        let value = [Userkey.fcmToken : fcm]
        FirebaseReference(.User).document(uid).setData(value, merge: true)
    }
    
    
    
    static func logOut(completion : @escaping(Result<Bool, Error>) -> Void) {
        
        do {
            try Auth.auth().signOut()
            completion(.success(true))
        } catch let error {
            completion(.failure(error))
        }
    }
}
