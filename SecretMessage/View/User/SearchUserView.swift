//
//  SearchUserView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI

struct SearchUserView: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        
        VStack {
            HStack {
                Button(action: {presentationMode.wrappedValue.dismiss()}) {
                    Image(systemName: "xmark")
                        .padding(.leading)
                    
                    
                }
            }
            .padding(.top,7)
            
            Divider()
            
            Spacer()
        }
        .foregroundColor(.primary)
        
      
    }
}

struct SearchField : View {
    
    @Binding var searchText : String
    @State private var isSearchng : Bool = false
    
    var action : () -> Void
    
    var body: some View {
        HStack {
            
            HStack {
                TextField("Search", text: $searchText)
                    .autocapitalization(.none)
                    .padding(.leading,24)
                    .onTapGesture {
                        isSearchng = true
                    }
            }
            .padding()
            .background(Color(.systemGray3))
            .cornerRadius(12)
            .padding(.trailing)
            .overlay(
                HStack {
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    
                    if isSearchng {
                        Button(action: {
                            self.searchText = ""
                            self.isSearchng = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .padding(.vertical)
                        }
                    }
                }
                .padding(.leading,12)
                .padding(.trailing,32)
                .foregroundColor(.primary)
            )
            .transition(.move(edge: .trailing))
            .animation(.spring())
            
            if isSearchng {
                Button(action: {
                    action()
                }) {
                    Text("Search")
                        .foregroundColor(.primary)
                }
                .disabled(searchText == "" ? true : false)
                .opacity(searchText == "" ? 0.3 : 1)
                .padding(.trailing,24)
                .padding(.leading,0)
                .transition(.move(edge: .trailing))
                .animation(.spring())
            }
            
        }
    }
}


struct SearchUserView_Previews: PreviewProvider {
    static var previews: some View {
        SearchUserView()
    }
}
