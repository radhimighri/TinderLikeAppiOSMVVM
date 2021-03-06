//
//  AuthService.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 30/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import Firebase

struct AuthCredentials {
    
    let email: String
    let password: String
    let fullname: String
    let profileImage: UIImage
}

struct AuthService {
    
    static func logUserIn(withEmail email: String, password: String,
                          completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredentials credentials: AuthCredentials,
                             completion: @escaping((Error?) -> Void )) {
        
        Service.uploadImage(image: credentials.profileImage) { imageUrl in
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                
                if let err = error {
                    print("DEBUG: Error signing user up \(err.localizedDescription)")
                    return
                }
                
                guard let uid = result?.user.uid else {return}
                
                let data = ["email": credentials.email,
                            "fullname": credentials.fullname,
                            "imageURLs": [imageUrl],
                            "uid": uid,
                            "age": 18] as [String : Any]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
            
        }
        
    }
}
