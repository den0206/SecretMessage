//
//  MessageView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct MessageView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    @StateObject var vm = MessageViewModel()
    
    @State private var isEditing = false
    
    
    var body: some View {
        VStack {
            
            ZStack {
                
                ScrollView {
                    ScrollViewReader { reader in
                        LazyVStack {
                            
                            ForEach(vm.messages) { message in
                                
                                MessageCell(message: message, currentUser: userInfo.user, withUser: userInfo.withUser)
                            }
                        }
                        
                    }
                }
                
                .padding(.vertical)
                
                if isEditing {
                    Color.black.opacity(0.6)
                        
                        .onTapGesture {
                            hideKeyBord()
                        }
                }
            }
            
            
            MessageTextField(text: $vm.text, editing: $isEditing, sendAction: {vm.sendTextMessage()})
        }
        .onAppear {
            appear()
        }.onDisappear {
            disappear()
        }
        
        //MARK: - Navigation Propert
        .navigationBarTitle(vm.withUser.name)
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    private func appear() {
        vm.setMessage(userInfo: userInfo)
        vm.loadMessage()
        userInfo.showMenu = false
    }
    
    private func disappear() {
        vm.removeListner()
        userInfo.showMenu = true
    }
}

struct MessageCell : View {
    
    var message : Message
    let currentUser : FBUser
    let withUser : FBUser
    
    @State private var isBlur = true
    
    var isCurrentUser : Bool {
        return message.userID == currentUser.uid
    }
    
    var body: some View {
        
        HStack(spacing : 15) {
            if !isCurrentUser {
                WebImage(url: withUser.avatarUrl)
                    .LogoImageModifier()
            } else {
                Spacer()
                
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 22))
                    
            }
            
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 5) {
                
                Text(message.text)
                    .messageModifier(isCurrentUser: isCurrentUser, isBlur: isBlur)
                
                if message.read && isCurrentUser {
                    Text("既読")
                        .font(.caption2)
                }
                Text(message.tmString)
                    .font(.caption2)
                    .padding(!isCurrentUser ? .trailing : .leading,10)
            }
            
            if isCurrentUser {
                WebImage(url: currentUser.avatarUrl)
                    .LogoImageModifier()
            } else {
                Image(systemName: "eye.circle.fill")
                    .font(.system(size: 22))
                
                Spacer()
            }
            
        }
        .padding(.horizontal,15)
        .id(message.id)
        .transition(AnyTransition.opacity.animation(.linear(duration: 0.7)))
    }
}

struct MessageTextField : View {
    
    @Binding var text : String
    @Binding var editing : Bool
    
    var sendAction : () -> Void
    
    let size : CGFloat = 45
    
    var body: some View {
        HStack {
            TextField("Enter Message", text: $text) { (editing) in
                self.editing = editing
            } onCommit: {
                self.editing = editing
            }
            .foregroundColor(.primary)
            .padding(.horizontal)
            .frame( height: size)
            .background(Color.gray.opacity(0.6))
            .clipShape(Capsule())
            
            if !isEmpty(field: text) {
                Button(action: {
                    hideKeyBord()
                    self.sendAction()
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.primary)
                        .frame(width: size, height: size)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                .padding(.horizontal,5)
                .transition(AnyTransition.opacity.animation(.linear(duration: 0.5)))
                
            }
            
        }
        .padding([.bottom, .horizontal],5)
    }
}
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}

extension WebImage {
    
    func LogoImageModifier(size : CGFloat = 30) -> some View {
        
        self
            .resizable()
            .frame(width: size, height: size)
            .clipShape(Circle())
    }
}
