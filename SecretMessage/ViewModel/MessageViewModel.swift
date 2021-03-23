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
    
    var unReadIds = [String]()
    var listenNewChat : Bool = false
    var reachLast = false
    private let limit = 10
    
    
    //MARK: - load
    
    func loadMessage() {
        
        guard !reachLast && !loading else {return}
        
        var ref : Query!
    
        if lastDoc == nil {
            ref = FirebaseReference(.Message).document(currentUser.uid).collection(chatRoomId).order(by: MessageKey.date, descending: true).limit(to: limit)
        } else {
            loading = true
            
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.loading = false
                }
                
                return
            }
            
            
            if snapshopt.documents.count < self.limit {
                self.reachLast = true
            }
            
            if self.lastDoc == nil {
                self.messages = snapshopt.documents.map({Message(dic: $0.data())}).reversed()
                
                self.addReadListner()
                
                self.lastDoc = snapshopt.documents.last
                self.ListenNewChat()
                            
            } else {
                /// more
                
                let moreMessage = snapshopt.documents.map({Message(dic: $0.data())}).reversed()
                
                self.addReadListner(moreMessages: moreMessage)
                if moreMessage.count < self.limit {self.reachLast = true}
                self.lastDoc = snapshopt.documents.last
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.messages.insert(contentsOf: moreMessage, at: 0)
                    
                    self.loading = false
                }
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
        
        updateRecentCounter(chatRoomID: chatRoomId, lastMessage: text, withUser: withUser)
        
        text = ""
        
    }
    
    func readMessage() {
        
        let users = [currentUser,withUser]
        let unreads = self.messages.filter({$0.read == false && $0.userID != currentUser.uid})
        
        guard unreads.count > 0 else {return}
        
        print("already\(unreads.count)")
        let value = [MessageKey.read : true]
        
        let sum = zip(users, unreads)
        
        sum.forEach { (unread) in
            let user = unread.0
            let message = unread.1
            
            
            FirebaseReference(.Message).document(user.uid).collection(chatRoomId).document(message.id).updateData(value)
            
            if let index = self.messages.firstIndex(of: message) {
                self.messages[index].read = true
                
            }
        }
    }
    
    func uploadReadStatus(message : Message) {
        let users = [currentUser,withUser]
        
        if !message.read {
            let value = [MessageKey.read : true]
            
            users.forEach { (user) in
                FirebaseReference(.Message).document(user.uid).collection(chatRoomId).document(message.id).updateData(value)
            }
            
            if let i = self.messages.firstIndex(of: message) {
                self.messages[i].read = true
            }
            
        }
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
                        self.listenNewChat.toggle()
                        
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
    
    private func addReadListner(moreMessages : ReversedCollection<[Message]>? = nil) {
        
        if moreMessages == nil {
            unReadIds =  self.messages.filter({$0.read != true && $0.userID == currentUser.uid}).map({$0.id})
        } else {
            let more = moreMessages!.filter({$0.read != true && $0.userID == currentUser.uid}).map({$0.id})
            
            guard more.count > 0 else {return}
            
            unReadIds.append(contentsOf: more)
        }
        
        guard unReadIds.count > 0 else {return}
        readListner = FirebaseReference(.Message).document(currentUser.uid).collection(chatRoomId).whereField(MessageKey.messageId, in: unReadIds).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else {return}
            
            print("unRead \(snapshot.documents.count)")
            snapshot.documentChanges.forEach { (diff) in
                switch diff.type {
                case .modified :
                    let editedMessage = Message(dic: diff.document.data())
                    
                    for i in 0 ..< self.messages.count {
                        let temp = self.messages[i]
                        
                        if editedMessage.id == temp.id {
                            self.messages[i] = editedMessage
                            self.messages[i].read = true
                        }
                        
                    }
                default :
                    return
                    
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
