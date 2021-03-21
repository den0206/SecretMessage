//
//  MessageViewModel.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import Foundation
import Firebase

final class MessageViewModel : ObservableObject {
    
    @Published var text : String = ""
    @Published var messages = [Message]()
    
    @Published var loading = false
    @Published var lastDoc : DocumentSnapshot?
    @Published var newChatListner : ListenerRegistration?
    @Published var readListner : ListenerRegistration?
    
    @Published var chatRoomId = ""
    @Published var currentUser = FBUser .init(uid: "", name: "", email: "", fcmToken: "", searchId: "")
    @Published var withUser = FBUser .init(uid: "", name: "", email: "", fcmToken: "", searchId: "")
    
    var reachLast = false
    private let limit = 10

    
    //MARK: - load
    
    func loadMessage() {
        
        guard !reachLast else {return}
        
        var ref : Query!
        
        if lastDoc == nil {
            ref = FirebaseReference(.Message).document(currentUser.uid).collection(chatRoomId).order(by: MessageKey.date, descending: true).limit(to: limit)
        } else {
            ref = FirebaseReference(.Message).document(currentUser.uid).collection(chatRoomId).order(by: MessageKey.date, descending: true).start(afterDocument: self.lastDoc!).limit(to: self.limit)
        }
        
        ref.getDocuments { (snapshopt, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snapshopt = snapshopt else {return}
            
            guard !snapshopt.isEmpty else {
                self.reachLast = true
                
                if self.newChatListner == nil {
                    self.ListenNewChat()
                }
                
                return
            }
            
            
            if self.lastDoc == nil {
                self.messages = snapshopt.documents.map({Message(dic: $0.data())}).reversed()
                
                self.lastDoc = snapshopt.documents.last
                
                self.ListenNewChat()
                
            } else {
                /// more
            }
        }
        
        
        
    }
    
    //MARK: - send
    
    func sendTextMessage() {
        guard !isEmpty(field: text) else {return}
        guard let ecrypText = Cryptography.shared.ecrypt(text: text) else {return}
        
        let messageId = UUID().uuidString
        let users = [currentUser, withUser]
        
        let data = [MessageKey.text : ecrypText,
                    MessageKey.messageId : messageId,
                    MessageKey.chatRoomId : chatRoomId,
                    MessageKey.userID : currentUser.uid,
                    MessageKey.read : false,
                    MessageKey.date : Timestamp(date: Date())
                    
        ] as [String : Any]
        
        users.forEach { (user) in
            FirebaseReference(.Message).document(user.uid).collection(chatRoomId).document(messageId).setData(data)
        }
        
        text = ""
        
    }
    
    //MARK: - add Lisner
    
    private func ListenNewChat() {
        
        var ref : Query!
        
        if messages.count > 0 {
            let lastTime = messages.last!.date
            
            ref = FirebaseReference(.Message).document(currentUser.uid).collection(chatRoomId).whereField(MessageKey.date, isGreaterThan: lastTime)
        } else {
           ref = FirebaseReference(.Message).document(currentUser.uid).collection(chatRoomId)
        }
        
        newChatListner = ref.addSnapshotListener({ (snapshot, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot else {return}
            guard !snapshot.isEmpty else {return}
            
            snapshot.documentChanges.forEach { (doc) in
                switch doc.type {
                
                case .added:
                    let message = Message(dic: doc.document.data())
                    
                    if !self.messages.contains(message) {
                        
                        self.messages.append(message)
                        
                    }
                    
                case .modified :
                    let editedMessage = Message(dic: doc.document.data())
                    
                    for i in 0 ..< self.messages.count {
                        let temp = self.messages[i]
                        
                        if editedMessage.id == temp.id {
                            self.messages[i] = editedMessage
                            self.messages[i].read = true
                        }
                        
                    }
                    
                case .removed :
                    print("Remove")
                default :
                    print("NO")
                }
            }
        })
    }
    
    
    
    /// sync User info
    func setMessage(userInfo : UserInfo) {
        self.chatRoomId = userInfo.chatRoomId
        self.currentUser = userInfo.user
        self.withUser = userInfo.withUser
    }
    
    func removeListner() {
        print("Remove Listner")
        newChatListner?.remove()
        readListner?.remove()
    }

    
}
