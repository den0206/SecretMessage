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
    @State private var showAlert = false
    
    var body: some View {
        
        NavigationView {
            VStack {
                NavigationLink(destination: FriendView(vm: FriendViewModel(user: userInfo.user)), isActive: $pushNav, label: {})
                
                DetailUserView(vm: DetailUserViewModel(user: userInfo.user), primaryAction: {showAlert.toggle()}, secoundryAction: {pushNav.toggle()})
                    .alert(isPresented: $showAlert, content: {
                        Alert(title: Text("ログアウトしますか?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("ログアウト"), action: {logOut()}))
                    })
               
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
