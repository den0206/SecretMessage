//
//  RecentsViewModel.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import Foundation
import FirebaseFirestore


final class RecentsViewModel : ObservableObject {
    
    @Published var recents = [Recent]()
    @Published var status = Status.plane
    @Published var recentsListner : ListenerRegistration?
    @Published var reachLast = false
    @Published var lastDoc : DocumentSnapshot?
    
    deinit {
        print("REmove")
        recentsListner?.remove()
    }
    
    private let limit = 5
    
    func fetchRecents() {
        
        guard let uid = FBUser.currentUID() else {return}
        
        guard !reachLast else {return}
        
        if lastDoc == nil {
            status = .loading
        }
        
        var ref : Query!
        
        if lastDoc == nil {
            ref = FirebaseReference(.Recent).whereField(RecentKey.userId, isEqualTo: uid).limit(to: limit)
        } else {
            ref = FirebaseReference(.Recent).whereField(RecentKey.userId, isEqualTo: uid).start(afterDocument: lastDoc!).limit(to: limit)
        }
        
        ref.getDocuments(completion: { (snapshot, error) in
            
            if let error = error {
                self.status = .error(error)
                return
            }
            guard let snapshot = snapshot else {return}
            guard !snapshot.isEmpty else {
                
                if self.lastDoc == nil {
                    self.status = .empty(.Recent)
                }
                
                self.reachLast = true
                return
                
            }
            
            if snapshot.documents.count < self.limit {
                self.reachLast = true
            }
            
            self.lastDoc = snapshot.documents.last
            
            snapshot.documents.forEach { (doc) in
                
                var recent = Recent(dic: doc.data())
                
                FBCommon.fetchUser(uid: recent.withUserId) { (result) in
                    switch result {
                    
                    case .success(let withUser):
                        
                        recent.withUser = withUser
                        
                        self.recents.append(recent)
                        self.recents.sort {$0.date.dateValue() > $1.date.dateValue()}
                        
                        self.status = .plane
                        
                    case .failure(let error):
                        self.status = .error(error)
                    }
                }
            }
        })
        
        
    }
    
    func addListner() {
        
        guard let uid = FBUser.currentUID() else {return}
        
        recentsListner = FirebaseReference(.Recent).whereField(RecentKey.userId, isEqualTo: uid).whereField(RecentKey.date, isGreaterThan: Timestamp(date: Date())).addSnapshotListener({ (snapshot, error) in
            
            if let error = error {
                self.status = .error(error)
                return
            }
            
            guard let snapshot = snapshot else {return}
            
            if !snapshot.isEmpty {
                snapshot.documentChanges.forEach { (diff) in
                    
                    var recent = Recent(dic: diff.document.data())
                    
                    switch diff.type {
                    
                    case .added:
                        print("Add")
                        for i in 0 ..< self.recents.count {
                            
                            let tempRecent = self.recents[i]
                            
                            if recent.id == tempRecent.id {
                                
                                recent.withUser = tempRecent.withUser
                                
                                self.recents[i] = recent
                                
                            }
                        }
                        
                        self.recents.sort {$0.date.dateValue() > $1.date.dateValue()}
                    default :
                        print("Default")
                    }
                }
            }
            
         
        })
    }
    
    
    
}
