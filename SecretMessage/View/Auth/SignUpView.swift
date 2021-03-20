//
//  SignUpView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI

struct SignUpView: View {
    
    @State private var user = AuthUserViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showPicker = false
    
    var body: some View {
        
        ScrollView {
            
            HStack {
                Button(action: {presentationMode.wrappedValue.dismiss()}, label: {
                    Image(systemName: "arrow.backward")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                })
                .padding()
                
                Spacer()
            }
            
            ValitaionText(text: user.validImageText, confirm: !user.selectedImage())
            
            Button(action: {showPicker = true}, label: {
                
                if user.imageData.count == 0 {
                    Image(systemName: "person.crop.circle")
                        .resizable()
                        .foregroundColor(.gray)
                } else {
                    Image(uiImage: UIImage(data: user.imageData)!)
                        .resizable().scaledToFill().clipShape(Circle())
                }
            })
            .frame(width: 140, height: 140)
            .padding(.vertical,15)
            .sheet(isPresented: $showPicker, content: {
                ImagePicker(image: $user.imageData)
            })
            
            Spacer()
            
            TextFiedsArea(user: $user)
            
            CustomButton(tilte: "Register", disable: user.isSignupComplete, action: {})
                .padding()
            
            Spacer()
        }
        
        .navigationBarHidden(true)
    }
}

//MARK: - Textfields

struct TextFiedsArea : View {
    
    @Binding var user : AuthUserViewModel
    
    var body: some View {
        
        VStack(spacing :8) {
            CustomTextField(text: $user.fullname, placeholder: "Fullname", imageName: "person")
            
            ValitaionText(text: user.validNameText, confirm: !user.validNameText.isEmpty)
            
            
            CustomTextField(text: $user.email, placeholder: "Email", imageName: "envelope")
            
            
            ValitaionText(text: user.validEmailText, confirm: !user.validEmailText.isEmpty)
            
            
            CustomTextField(text: $user.searchID, placeholder: "SearchID", imageName: "magnifyingglass")
            
            ValitaionText(text: user.validSearchText, confirm: !user.validSearchText.isEmpty)
            
            
            CustomTextField(text: $user.password, placeholder: "Password", imageName: "lock",isSecure: true)
            
            
            ValitaionText(text: user.validPasswordText,confirm: !user.validPasswordText.isEmpty)
            
            
            CustomTextField(text: $user.confirmPassword, placeholder: "Password confirmation", imageName: "lock",isSecure: true)
            
            
            ValitaionText(text: user.validConfirmPasswordText,confirm: !user.passwordMatch(_confirmPass: user.confirmPassword) )
            
            
        }
    }
}

//MARK: - IMagePicker

struct ImagePicker : UIViewControllerRepresentable {
    
    @Binding var image : Data
    @Environment(\.presentationMode) var presentationMode
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> some UIImagePickerController {
        
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    /// Coordinator
    
    class Coordinator : NSObject,UINavigationControllerDelegate,UIImagePickerControllerDelegate {
        
        let parent : ImagePicker
        
        init(_ parent : ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            if let image = info[.originalImage] as? UIImage {
                guard let data = image.jpegData(compressionQuality: 0.2) else {return}
                let dataKB = Double(data.count) / 1000.0
                
                if dataKB < 1000.0 {
                    self.parent.image = data
                } else {
                    return
                }
                
                parent.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
