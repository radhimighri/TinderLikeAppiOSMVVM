//
//  ProfileViewModel.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 01/11/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

struct ProfileViewModel {
    
    private let user: User
    
    let userDatailsAttributedString: NSAttributedString
    let profession: String
    let bio: String
    
    var imageURLs: [URL] {
        return user.imageURLs.map({ URL(string: $0)! })
    }
    
    var imageCount: Int {
        return user.imageURLs.count
    }
    
    init(user: User) {
        self.user = user
        
        let attributedText = NSMutableAttributedString(string: user.name,
                                                       attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .semibold)])
        
        attributedText.append(NSAttributedString(string: " \(user.age)",
            attributes: [.font: UIFont.systemFont(ofSize: 22)]))
        
        userDatailsAttributedString = attributedText
        profession = user.profession
        bio = user.bio
    }
}
