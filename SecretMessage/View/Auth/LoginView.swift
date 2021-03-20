//
//  LoginView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/19.
//

import SwiftUI

struct LoginView: View {

    @State private var user = AuthUserViewModel()
    @EnvironmentObject var monitor : NetMonitor
    
    var body: some View {
        NavigationView {
            
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
                    
                    CustomButton(tilte: "Login", disable: user.isLoginComplete && monitor.isActive, action: {loginUser()})
                    
                    NavigationLink(
                        destination: SignUpView(),
                        label: {
                            CustomButton(tilte: "SignUp", disable: true, backColor: .blue)
                                .disabled(true)
                        })
                  
                }
                
                ValitaionText(text: "No InterNet", confirm: !monitor.isActive)

                Spacer()
                
            }
            
            //MARK: - Navigation property
            .navigationBarHidden(true)
        }
    
    }
    
    private func loginUser() {
        
        guard monitor.isActive else {return}
        
        FBAuth.loginUser(email: user.email, password: user.password) { (result) in
            
            switch result {
            
            case .success(let uid):
                print("Success\(uid)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }

}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
