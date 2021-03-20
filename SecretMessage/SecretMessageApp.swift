//
//  SecretMessageApp.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/19.
//

import SwiftUI
import Firebase

public var testMode = true

@main
struct SecretMessageApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    var userInfo = UserInfo()
    var network = NetMonitor()
    
    var body: some Scene {
        WindowGroup {
            MainMenuView()
.environmentObject(userInfo).environmentObject(network)
        }
    }
}

