//
//  FriendView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var vm : FriendViewModel
    @State private var firstLoad = true
    
    var body: some View {
        
        VStack {

            NavigationLink(
                destination: DetailUserView(vm: DetailUserViewModel(user: vm.selectedFriends!),type : .profile),
                isActive: $vm.pushNav, label: {})
            
            switch vm.status {
            case .plane :
                List {
                    ForEach(vm.friends, id : \.uid) { friend in
                        
                        Button(action: {
                            vm.selectedFriends = friend
                        }, label: {
                            
                            FriendCell(friend: friend)
                        })
                        .onAppear(perform: {
                            if friend.uid == vm.friends.last?.uid {
                                vm.fetchFriend()
                            }
                        })
                        
                    }
                }
                .listStyle(PlainListStyle())
            default :
                StatusView(status: vm.status, retryAction: {})
            }
        }
        .onAppear(perform: {
            appear()
        })
        .onDisappear(perform: {
            disappear()
        })
        
        //MARK: - navigation proprty
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Friends")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:  Button(action: {presentationMode.wrappedValue.dismiss()}) {
            Image(systemName:  "chevron.left")
                .foregroundColor(.primary)
        })
    }
    
    private func appear() {
        if firstLoad {
            vm.fetchFriend()
            firstLoad = true
        }
    }
    
    private func disappear() {
        if !vm.pushNav {
            vm.friendListner?.remove()
        }
    }
}


struct FriendCell : View {
    let friend : FBUser
    
    var body: some View {
        
        HStack {
            
            WebImage(url: friend.avatarUrl)
                .LogoImageModifier(size: 60)
            
            Spacer()
            
            Text(friend.name)
            
            Spacer()
            
        }
        .padding()
        .foregroundColor(.primary)
        
    }
}

