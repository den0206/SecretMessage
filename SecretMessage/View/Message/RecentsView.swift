//
//  RecentsView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI

struct RecentsView: View {
    
    @State private var showSheet = false
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                Text("Recents")
            }
            
            //MARK: -
            .navigationBarTitle(Text("Messages"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {showSheet = true}, label: {
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 25))
                    .foregroundColor(.primary)
                    .sheet(isPresented: $showSheet) {
                        SearchUserView()
                    }
            }))
            
        }
    }
}

struct RecentsView_Previews: PreviewProvider {
    static var previews: some View {
        RecentsView()
    }
}
