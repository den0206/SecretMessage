//
//  MessageView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import SwiftUI

struct MessageView: View {
    
    @EnvironmentObject var userInfo : UserInfo

    var body: some View {
        VStack {
            Text(userInfo.chatRoomId)
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}
