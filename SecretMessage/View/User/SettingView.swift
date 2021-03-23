//
//  SettingView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI

struct SettingView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    @State private var pushNav : Bool = false

    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink(destination: FriendView(), isActive: $pushNav, label: {})
                
                DetailUserView(vm: DetailUserViewModel(user: userInfo.user), primaryAction: {logOut()}, secoundryAction: {pushNav.toggle()})
               
            }
        }
        
        .navigationBarHidden(true)
        .navigationBarTitleDisplayMode(.inline)
       
    }
    
    private func logOut() {
        FBAuth.logOut { (result) in
            switch result {
            
            case .success(let bool):
                print("Succes\(bool)")
                userInfo.isUserAuthenticated = .signOut
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}


//MARK: - burttonModifier

struct ProfileButtonModifier : ViewModifier {
    
    let color : Color
    
    func body(content: Content) -> some View {
        content
            .frame(width: 140, height: 50)
            .background(color)
            .foregroundColor(.primary)
            .cornerRadius(20)
    }
}
