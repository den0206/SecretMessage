//
//  AuthUserViewModel.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/19.
//

import Foundation

struct AuthUserViewModel {
    
    var email = ""
    var fullname = ""
    var password = ""
    var confirmPassword = ""
    
    var searchID = ""
    var imageData : Data = .init(count: 0)
    
    var isLoginComplete : Bool {
        
        if isEmpty(field: email) || isEmpty(field: password) ||  !isEmailValid(email: email){
            return false
        }
        return true
    }
    
    var isSignupComplete : Bool {
        
        
        if testMode {
            if !selectedImage() || !isEmailValid(email: email) || isEmpty(field: fullname) || !passwordMatch(_confirmPass: confirmPassword) || isEmpty(field: password) || isEmpty(field: searchID) || !isSearchValid(searchId: searchID){
                return false
            }
            
            return true
        } else {
            if !selectedImage() || !isEmailValid(email: email) || isEmpty(field: fullname) || !passwordMatch(_confirmPass: confirmPassword) || !isPasswordValid(password: password) || isEmpty(field: searchID) || !isSearchValid(searchId: searchID){
                return false
            }
            
            return true
        }
        
    }
    
    //MARK: - Valitadion
    
    func selectedImage() -> Bool {
        return !(imageData == .init(count : 0))
    }
    
    func passwordMatch(_confirmPass : String) -> Bool {
        
        guard !password.isEmpty else {return false}
        return _confirmPass == password
    }
    
    
    func isEmailValid(email : String) -> Bool {
        let emailRegex = "^([A-Z0-9a-z._+-])+@([A-Za-z0-9.-])+\\.([A-Za-z]{2,})$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
    
    func isSearchValid(searchId : String) -> Bool {
        let searchIdRegEx = "[A-Za-z]{4,8}?"
        let searchIdTest = NSPredicate(format: "SELF MATCHES %@", searchIdRegEx)

        return searchIdTest.evaluate(with: searchID)
    }
    
    func isPasswordValid(password : String) -> Bool {
        let passwordRegEx = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        
        return passwordTest.evaluate(with: password)
    }
    
    
    //MARK: - error Message
    
    var validImageText : String {
        
        if selectedImage() {
            return ""
        } else {
            return "画像を選択してください"
        }
    }
    
    var validNameText : String {
        
        if !isEmpty(field: fullname) {
            return ""
        } else {
            return "名前を入力してください"
        }
    }
    
    var validEmailText : String {
        if isEmailValid(email: email) {
            return ""
        } else {
            return "Emailの書式を入力してください"
        }
    }
    
    var validSearchText : String {
        if isSearchValid(searchId: searchID) {
            return ""
        } else {
            return "4文字以上,8文字以内,英数字を含めてください"
        }
    }
    
    var validPasswordText : String {
        if isPasswordValid(password: password){
            return ""
        } else {
            return "8文字以上で、大文字もふくめてください"
        }
    }
    
    var validConfirmPasswordText : String {
        if passwordMatch(_confirmPass: confirmPassword) {
            return ""
        } else {
            return "確認用パスワードが一致しません"
        }
    }
    
    
    
}
