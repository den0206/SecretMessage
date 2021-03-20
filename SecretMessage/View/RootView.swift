//
//  RootView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    
    var body: some View {
        Group {
            MainMenuView()
//            switch userInfo.isUserAuthenticated {
//
//            case .undefined :
//                ProgressView()
//            case .signOut :
//                LoginView()
//            case .signIn :
//                MainMenuView()
//            }
            
        }
        .onAppear(perform: {
            userInfo.configureStateDidchange()
        })
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
