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
    
    static func fetchUsers(forCurrentUser user: User, completion: @escaping([User]) -> Void) {
            var users = [User]()
            
        let minAge = user.minSeekingAge
        let maxAge = user.maxSeekingAge
        
        let query = COLLECTION_USERS
            .whereField("age", isGreaterThanOrEqualTo: minAge)
            .whereField("age", isLessThanOrEqualTo: maxAge)
        
        fetchSwipes { swipedUserIDs in
            query.getDocuments { (snapshot, error) in
                 guard let snapshot = snapshot else {return}
                 snapshot.documents.forEach({ document in
                     let dictionary = document.data()
                     let user = User(dictionary: dictionary)
                     
                     guard user.uid != Auth.auth().currentUser?.uid else {return}
                    guard swipedUserIDs[user.uid] == nil else {return}
                     users.append(user)
                     
//                     if users.count == snapshot.documents.count - 1 { //execute the completion(user) only one time : when we finish filling up the users array (-1 : minus the current user)
//                         completion(users)
//                     }
                 })
                completion(users)
             }
        }
 
        }
    
    private static func fetchSwipes(completion: @escaping([String : Bool]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_SWIPES.document(uid).getDocument { (snapshot, err) in
            guard let data = snapshot?.data() as? [String : Bool] else {
                completion([String : Bool]())// if the current user didn't swipe yet, we just return an empty array String:Bool with the completion

                return
            }
            
            completion(data)
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
    
    static func saveSwipe(forUser user: User, isLike: Bool, completion: ((Error?)-> Void)?) {
        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let shouldLike = isLike ? 1 : 0
        
        COLLECTION_SWIPES.document(uid).getDocument { (snapshot, err) in
            let data = [user.uid: isLike]
            
            if snapshot?.exists == true {
                COLLECTION_SWIPES.document(uid).updateData(data, completion: completion)
            } else {
                COLLECTION_SWIPES.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    static func checkIfMatchExists(forUser user: User, completion: @escaping(Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {return}
        
        COLLECTION_SWIPES.document(user.uid).getDocument { (snapshot, error) in
            guard let data = snapshot?.data() else {return}
            guard let didMatch = data[currentUid] as? Bool else {return}
            completion(didMatch)
        }
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
