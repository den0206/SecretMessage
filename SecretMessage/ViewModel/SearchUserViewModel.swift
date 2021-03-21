//
//  SearchUserViewModel.swift
//  SecretMessage
//
//  Created by 酒井ゆうき on 2021/03/20.
//

import SwiftUI

final class SearchUserViewModel : ObservableObject {
    
    @Published var searchText : String = ""
    @Published var searchedUser : FBUser?
    @Published var status : Status = .plane
    
    func searchUser() {
        
        guard searchText != "" else {return}
        
        status = .loading
        
        FBCommon.searchUser(searchId: searchText) { (result) in
            switch result {
            
            case .success(let user):
                self.searchedUser = user
                self.status = .plane
            case .failure(let error):
                self.status = .error(error)
            }
            
            self.searchText = ""
        }

    }
    
    
    
}
