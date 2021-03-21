//
//  DetailUserView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct DetailUserView : View {
    
    enum DetailType  {
        case search, profile
    }
    
    @EnvironmentObject var userInfo : UserInfo
    @StateObject var vm : DetailUserViewModel
    
    var user : FBUser {
        return vm.user
    }

    var type : DetailType = .profile

    var primaryAction : (() -> Void?)? = nil
    var secoundryAction : (() -> Void?)? = nil
    
    var body: some View {
        VStack {
            WebImage(url: user.avatarUrl)
                .resizable()
                .placeholder{
                    Circle().fill(Color.gray)
                }
                .scaledToFill()
                .clipped()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white,lineWidth: 4))
                .shadow(color: .primary, radius: 10)
        }
        .padding()
        
        VStack {
            Text(user.name)
                .bold()
                .font(.title)
            
        }
        .padding()
        .padding(.top,20)
        
        if user.isCurrentUser {
            switch type {
            case .search :
                Text("このユーザーはあなたです。")
            case .profile :
                HStack {
                    Button(action: {
                        if primaryAction != nil {
                            primaryAction!()
                        }
                    }) {
                        Text("LogOut")
                            .modifier(ProfileButtonModifier(color: .red))
                    }
                    
                    Button(action: {
                        if secoundryAction != nil {
                            secoundryAction!()
                        }
                    }) {
                        Text("Friends")
                            .modifier(ProfileButtonModifier(color: .green))
                    }
                }
            }
          
        } else {
            HStack {
                Button(action: {
                    if primaryAction != nil {
                        primaryAction!()
                    }
                }) {
                    Text("+ Friend")
                        .modifier(ProfileButtonModifier(color: .blue))
                }
                
                Button(action: {
                    if secoundryAction != nil {
                        secoundryAction!()
                        vm.startPrivateChat(userInfo: userInfo)

                    }
                }) {
                    Text("Message")
                        .modifier(ProfileButtonModifier(color: .green))
                }
            }
        }
    }
}
