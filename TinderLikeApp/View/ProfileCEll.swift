//
//  ProfileCell.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 01/11/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    //MARK:- Properties
    let imageView = UIImageView()
    
    //MARK:- LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .scaleAspectFill
        
        addSubview(imageView)
        imageView.fillSuperview()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
