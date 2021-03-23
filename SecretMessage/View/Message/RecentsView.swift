//
//  RecentsView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecentsView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    @StateObject var vm = RecentsViewModel()
    @State private var showSheet = false
    @State private var firstLoad = true
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                NavigationLink(destination: MessageView(),isActive: $userInfo.MSGPushNav,label: {})
            
                switch vm.status {
                case .plane :
                    List {
                        ForEach(vm.recents) { recent in
                            
                            Button(action: {
                                userInfo.pushMessageView(chatRoomId: recent.chatRoomId, withUser: recent.withUser)
                            }, label: {
                                RecentCell(recent: recent)
                            })
                            .onAppear(perform: {
                                    if recent.id == vm.recents.last?.id {
                                        print("More")
                                        vm.fetchRecents()
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
                print("Appear")
                
                if firstLoad {
                    vm.addListner()
                    firstLoad = false
                }
                vm.fetchRecents()
            })
            
            //MARK: -
            .navigationBarTitle(Text("Messages"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {showSheet = true}, label: {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 25))
                    .foregroundColor(.primary)
                    .sheet(isPresented: $showSheet) {
                        SearchUserView()
                    }
            }))
            
        }
    }
}

struct RecentCell : View {
    
    let recent : Recent
    
    var body: some View {
        
        HStack {
            WebImage(url: recent.withUser.avatarUrl)
                .resizable()
                .placeholder {
                    Circle().fill(Color.gray)
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            Spacer()
            
            VStack() {
                Text(recent.withUser.name)
                
                Spacer()
                
                Text(recent.lastMessage)
                    .font(.caption)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(spacing : 10) {
                
                if recent.counter > 0 {
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 30, height: 30)
                        .overlay(Text("\(recent.counter)"))
                }
                
                
                Text(recent.tmString)
                    .font(.caption2)
                
            }
            
            
        }
        .padding()
        .foregroundColor(.primary)
        
        
    }
}

struct RecentsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentsView()
    }
}
