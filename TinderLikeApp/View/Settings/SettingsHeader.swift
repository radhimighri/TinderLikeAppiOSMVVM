//
//  SettingsHeader.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 30/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import SDWebImage

protocol SettingsHeaderDelegate: class {
    func settingsHeader(_ header: SettingsHeader, didSelect index: Int)
}
class SettingsHeader: UIView {
    
    //MARK:- Properties
    private let user: User
    weak var delegate: SettingsHeaderDelegate?
    
    var buttons = [UIButton]()
    
    //MARK:- LifeCycle
     init(user: User) {
        self.user = user
        super.init(frame: .zero)
        backgroundColor = .systemGroupedBackground

        let btn1 = createButton(0)
        let btn2 = createButton(1)
        let btn3 = createButton(2)
        

        buttons.append(btn1)
        buttons.append(btn2)
        buttons.append(btn3)
        
        addSubview(btn1)
        btn1.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor,
                    paddingTop: 16, paddingLeft: 16, paddingBottom: 16)
        btn1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.45).isActive = true
        
        let stack = UIStackView(arrangedSubviews: [btn2, btn3])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 16
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: btn1.rightAnchor, bottom: bottomAnchor,
                     right: rightAnchor, paddingTop: 16, paddingLeft: 16, paddingBottom: 16,  paddingRight: 16)
        
        loadUserPhotos()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Actions (Selectors)
    @objc func handleSelectPhoto(sender: UIButton) {
        print("DEBUG: Show photo selector here..")
        delegate?.settingsHeader(self, didSelect: sender.tag)
    }
    
    //MARK:- Helper Functions
    
    func loadUserPhotos() {
        let imageURLs = user.imageURLs.map ({ URL(string: $0) })
        for (index, url) in imageURLs.enumerated() {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.buttons[index].setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    func createButton(_ index: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle("Select Photo", for: .normal)
        btn.layer.cornerRadius = 10
        btn.addTarget(self, action: #selector(handleSelectPhoto), for: .touchUpInside)
        btn.clipsToBounds = true
        btn.backgroundColor = .white
        btn.imageView?.contentMode = .scaleAspectFill
        btn.tag = index
        return btn
    }
}

