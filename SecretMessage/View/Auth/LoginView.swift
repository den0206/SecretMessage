//
//  LoginView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/19.
//

import SwiftUI

struct LoginView: View {
    
    enum viewSheet : Identifiable {
        case signUp, resetPassword
        
        var id : Int {
            hashValue
        }
    }
    
    @State private var user = AuthUserViewModel()
    
    
    var body: some View {
        VStack(spacing :8) {
            
            Spacer()
            
            CustomTextField(text: $user.email, placeholder: "Email", imageName: "envelope")
            
            CustomTextField(text:$user.password, placeholder: "Pasword", imageName: "lock",isSecure: true)
            
            HStack {
                Spacer()
                
                Button(action: {}) {
                    Text("Reset Password")
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical)
            .padding(.trailing,10)
            
            VStack {
                
                CustomButton(tilte: "Login", disable: user.isLoginComplete, action: {})
                
                CustomButton(tilte: "SignUp", disable: true, backColor: .blue, action: {})
            }
            
            Spacer()
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
