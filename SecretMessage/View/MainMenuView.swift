//
//  MainMenuView.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI

struct MainMenuView: View {
    
    @EnvironmentObject var userInfo : UserInfo
    
    var body: some View {
        
        ZStack {
            
            switch userInfo.selectMenuIndex {
            
            case 0 :
                RecentsView()
            case 1 :
                SettingView()
            default:
                BlankView()
            }
            
            if userInfo.showMenu {
                MenuArea()

            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MenuArea : View {
    @EnvironmentObject var userInfo : UserInfo

    var body: some View {
      
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                ExpandingButton(primaryButton: ExpandingButtonItem(imageName: "plus", action: nil),
                                secoundaryItems: [
                                    ExpandingButtonItem(imageName: "message",  action: {userInfo.selectMenuIndex = 0}),
                                    ExpandingButtonItem(imageName: "gearshape",  action: {userInfo.selectMenuIndex = 1}),   ])
            }
            .padding()
        }
    }
}

struct  ExpandingButtonItem : Identifiable {
    let id = UUID()
    let imageName : String
    var color : Color = Color.white
    
    private(set) var action : (() -> Void)? = nil
}


struct ExpandingButton : View {
    
    let primaryButton : ExpandingButtonItem
    let secoundaryItems : [ExpandingButtonItem]
    
    private let noop : () -> Void = {}
    private let size : CGFloat = 70
    
    private var cornarRadius : CGFloat {
        return size / 2
    }
    
    private let shadowColor = Color.black.opacity(0.4)
    private let shadowPosition : (x : CGFloat, y : CGFloat) = (x : 2, y : 2)
    private let shadowRadius : CGFloat = 3
    
    @State private var isExpanded = false
    
    
    var body: some View {
        VStack {
            ForEach(secoundaryItems) { item in
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                    (item.action ?? self.noop)()
                    
                }) {
                    Image(systemName: item.imageName)
                    
                    
                }
                .foregroundColor(item.color)
                .frame(width: isExpanded ? self.size : 0,height:isExpanded ? self.size : 0)
                
            }
            
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
                self.primaryButton.action?()
            }) {
                Image(systemName: primaryButton.imageName)
                
            }
            .foregroundColor(primaryButton.color)
            .frame(width: size, height: size)
            
            
        }
        .background(Color.green)
        .cornerRadius(cornarRadius)
        .font(.title)
        .shadow(color: shadowColor, radius: shadowRadius, x: shadowPosition.x, y: shadowPosition.y)
    }
}
