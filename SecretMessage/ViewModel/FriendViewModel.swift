//
//  FriendViewModel.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/24.
//

import Foundation
import  FirebaseFirestore

final class FriendViewModel : ObservableObject {
    
    @Published var friends = [FBUser]()
    @Published var status : Status = .plane
    
    @Published var pushNav = false
    @Published var selectedFriends : FBUser? {
        didSet {
            pushNav = true
        }
    }
    
    var friendListner : ListenerRegistration?
    
    var reachLast = false
    var limit = 5
    var per_page = 5
    
    var user : FBUser
    
    init(user : FBUser) {
        self.user = user
    }
    
    func fetchFriend() {
        
        guard user.isCurrentUser && !reachLast else {return}
        
        friendListner = FirebaseReference(.User).document(user.uid).collection(FriendKey.friends).limit(to: 5).addSnapshotListener({ (snapshot, error) in
            
            if let error = error {
                self.status = .error(error)
                return
            }
            
            guard let snapshot = snapshot else {
                self.status = .error(FirestoreError.noDocumentSNapshot)
                return
                
            }
            
            guard !snapshot.isEmpty else {
                self.status = .empty(.Friend)
                self.reachLast = true
                return
            }
            
            if snapshot.documents.count < self.limit {
                print("Reach last")
                self.reachLast = true
            } else {
                self.limit += self.per_page
            }
                        
            self.diffType(diffs: snapshot.documentChanges)
        })
        
    }
    
    private func diffType(diffs : [DocumentChange]) {
        
        let uids = self.friends.map({$0.uid})
        
        diffs.forEach { (diff) in
            let data = diff.document.data()
            let uid = data[FriendKey.userID] as? String ?? ""
            
            switch diff.type {
            
            case .added :
                
                guard !uids.contains(uid) && uid != "" else {return}
                
                FBCommon.fetchUser(uid: uid) { (result) in
                    switch result {
                    
                    case .success(let user):
                        
                        if !self.friends.contains(user) {
                            self.friends.append(user)
                        }
                        self.status = .plane
                        
                    case .failure(let error):
                        self.status = .error(error)
                    }
                    
                }
            case .removed :
                
                guard let index = self.friends.map({$0.uid}).firstIndex(of: uid) else { return }
                self.friends.remove(at: index)
                
            default :
                print("Default")
            }
        }
    }
    
    
    
}
