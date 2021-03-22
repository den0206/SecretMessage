//
//  MessageView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/21.
//

import SwiftUI

struct MessageView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userInfo : UserInfo
    @StateObject var vm = MessageViewModel()
    
    @State private var isEditing = false
    @State private var tfSize : CGSize = .zero
    
    @State var isFirst : Bool = true
    
    var body: some View {
        
        ZStack {
            
            ScrollView {
                
                if vm.loading {
                    GreenProgressView()
                }
                
                ScrollViewReader { reader in
                    LazyVStack {
                        
                        ForEach(vm.messages) { message in
                            
                            MessageCell(message: message,vm: vm)
                                .onAppear {
                                    if message.id == vm.messages.first?.id {
                                        
                                        if !isFirst {
                                            vm.loadMessage()
                                        }
                                        
                                        if isFirst {
                                            reader.scrollTo(vm.messages.last?.id, anchor: .bottom)
                                            isFirst = false
                                        }
                                    }
                                }
                        }
                    }
                    .onChange(of: vm.listenNewChat) { (_) in
                        reader.scrollTo(vm.messages.last?.id, anchor: .bottom)
                    }
                    
                }
            }
            
            .padding(.vertical)
            .padding(.bottom,tfSize.height)
            
            
            if isEditing {
                Color.black.opacity(0.6)
                    .onTapGesture {
                        hideKeyBord()
                    }
            }
            
            MessageTextField(text: $vm.text, editing: $isEditing, tfSize: $tfSize, sendAction: {vm.sendTextMessage()})
         
            
        }
        .onAppear {
            appear()
        }.onDisappear {
            disappear()
        }
        
        //MARK: - Navigation Propert
        .navigationBarTitle(vm.withUser.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "arrow.backward")
                .foregroundColor(.primary)
                
        }))
        
    }
    
    private func appear() {
        vm.setMessage(userInfo: userInfo)
        vm.loadMessage()
        userInfo.showMenu = false
    }
    
    private func disappear() {
        vm.removeListner()
        userInfo.showMenu = true
    }
}


struct MessageTextField : View {
    
    @Binding var text : String
    @Binding var editing : Bool
    @Binding var tfSize : CGSize
    
    var sendAction : () -> Void
    
    let size : CGFloat = 45
    
    var body: some View {
        VStack {
            Spacer()
            
            ChildSizeReader(size: $tfSize) {
                HStack {
                    TextField("Enter Message", text: $text) { (editing) in
                        self.editing = editing
                    } onCommit: {
                        self.editing = editing
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .frame( height: size)
                    .background(!editing ? Color.gray.opacity(0.6) : .white)
                    .clipShape(Capsule())
                    
                    if !isEmpty(field: text) {
                        Button(action: {
                            hideKeyBord()
                            self.sendAction()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.primary)
                                .frame(width: size, height: size)
                                .background(Color.green)
                                .clipShape(Circle())
                        }
                        .padding(.horizontal,5)
                        .transition(AnyTransition.opacity.animation(.linear(duration: 0.5)))
                        
                    }
                    
                }
                .padding([.bottom, .horizontal],5)
            }
            
            
        }
        
    }
}
struct MessageView_Previews: PreviewProvider {
    static var previews: some View {
        MessageView()
    }
}



struct TapTestView: View {
    
    @GestureState var isTapped : Bool
    
    var body: some View {
        
        let tap = DragGesture(minimumDistance: 0)
            .updating($isTapped) { (_, isTapped, _) in
                isTapped = false
            }
        
        return  Image(systemName: "eye.circle.fill")
            .font(.system(size: 22))
            .gesture(tap)
    }
}
