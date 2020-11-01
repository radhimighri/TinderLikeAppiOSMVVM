//
//  Service.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 30/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import Firebase

struct Service {
    
    static func fetchUser(withUid uid: String, completion: @escaping(User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { (snapshot, error) in
//            print("DEBUG: Snapshot \(snapshot?.data())")
            guard let dictionary = snapshot?.data() else {return}
            let user = User(dictionary: dictionary)
            completion(user)
        }
    }
    
       static func fetchUsers(completion: @escaping([User]) -> Void) {
            var users = [User]()
            
            COLLECTION_USERS.getDocuments { (snapshot, error) in
                snapshot?.documents.forEach({ document in
                    let dictionary = document.data()
                    let user = User(dictionary: dictionary)
                    
                    users.append(user)
                    
                    if users.count == snapshot?.documents.count { //execute the completion(user) only one time : when we finish filling up the users array
                        completion(users)
                    }
                })
            }
        }
    
    
    static func saveUserData(user: User, completion: @escaping(Error?) -> Void ) {
        
        let data = ["uid": user.uid,
                    "fullname": user.name,
                    "imageURLs": user.imageURLs,
                    "age": user.age,
                    "bio": user.bio,
                    "profession": user.profession,
                    "minSeekingAge": user.minSeekingAge,
                    "maxSeekingAge": user.maxSeekingAge
            ] as [String : Any]
        COLLECTION_USERS.document(user.uid).setData(data, completion: completion)
    }
    
    
    static func uploadImage(image: UIImage, completion: @escaping(String) -> Void) {
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else {return}
        let filename = NSUUID().uuidString
        let imageRef = Storage.storage().reference(withPath: "images/\(filename)")
        
        imageRef.putData(imageData, metadata: nil) { (metadata, err) in
            
            if let error = err {
                print("DEBUG: Error uploading image \(error.localizedDescription)")
                return
            }
            
            imageRef.downloadURL { (url, error) in
                
                guard let imageUrl = url?.absoluteString else {return}
                completion(imageUrl)
            }
        }
    }
}
