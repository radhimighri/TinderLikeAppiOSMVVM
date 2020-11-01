//
//  User.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 28/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

struct User {
    let uid: String
    var email: String
    var name: String
    var age: Int
    var imageURLs: [String]
//    var images: [UIImage]
    var profession: String
    var bio: String
    var minSeekingAge: Int
    var maxSeekingAge: Int

    
    init(dictionary: [String: Any]) {
        self.name = dictionary["fullname"] as? String ?? ""
        self.age = dictionary["age"] as? Int ?? 0
        self.email = dictionary["email"] as? String ?? ""
        self.imageURLs = dictionary["imageURLs"] as? [String] ?? [String]()
        self.uid = dictionary["uid"] as? String ?? ""
        self.profession = dictionary["profession"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int ?? 18
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int ?? 60


    }
}
