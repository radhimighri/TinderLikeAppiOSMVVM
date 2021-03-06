//
//  CardViewModel.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 28/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

class CardViewModel {
    
    let user: User
    let imageURLs: [String]
    
    let userInfoText: NSAttributedString
    private var imageIndex = 0
    var index: Int { return imageIndex }
    var imageUrl: URL?
    
    init(user: User) {
        self.user = user
        
        let attributedText = NSMutableAttributedString(string: user.name, attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy), .foregroundColor: UIColor.white])
        
        attributedText.append(NSAttributedString(string: "  \(user.age)", attributes: [.font: UIFont.systemFont(ofSize: 24), .foregroundColor: UIColor.white]))
        
        self.userInfoText = attributedText
        
//        self.imageUrl = URL(string: user.profileImageUrl)
        self.imageURLs = user.imageURLs
        self.imageUrl = URL(string: self.imageURLs[0])
    }
    
    func showNextPhoto() {
        print("DEBUG: Show Next Photo")
        guard imageIndex < imageURLs.count - 1 else {
            print("DEBUG: Image index trying to go out of bounds...")
            return
        }
        imageIndex += 1
        print("DEBUG: Image index is : \(imageIndex)")
        imageUrl = URL(string: imageURLs[imageIndex])

    }
    
    func showPreviousPhoto() {
        print("DEBUG: Show Previous Photo")
        guard imageIndex > 0 else {return}
        imageIndex -= 1
        imageUrl = URL(string: imageURLs[imageIndex])
    }
    
}
