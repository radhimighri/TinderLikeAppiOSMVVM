//
//  MatchViewViewModel.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 02/11/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import Foundation

struct MatchViewViewModel {
    
    private let currentUser: User
    let matchedUser: User
    
    let matchLabelText: String
    
    var currentUserImageURL: URL?
    var matchedUserImageURL: URL?

    init(currentUser: User, matchedUser: User) {
        self.currentUser = currentUser
        self.matchedUser = matchedUser

        matchLabelText = "You and \(matchedUser.name) have liked each other!"
        
        guard let imageURLString = currentUser.imageURLs.first else {return}
        guard let matchedImageUrlString = matchedUser.imageURLs.first else {return}
        
        currentUserImageURL = URL(string: imageURLString)
        matchedUserImageURL = URL(string: matchedImageUrlString)
    }
}
