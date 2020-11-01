//
//  SettingsFooter.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 31/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

protocol SettingsFooterDelegate: class {
    func handleLogout()
}

class SettingsFooter: UIView {
    
    //MARK:- Properties
    
    weak var delegate: SettingsFooterDelegate?
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Logout", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return button
    }()
    
    
    //MARK:- LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let spacer = UIView()
        spacer.backgroundColor = .systemGroupedBackground
        
        addSubview(spacer)
        spacer.setDimensions(height: 32, width: frame.width)
        
        addSubview(logoutButton)
        logoutButton.anchor(top: spacer.bottomAnchor, left: leftAnchor,
                            right: rightAnchor, height: 50)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Actions (Selectors)
    
    @objc func handleLogout() {
        delegate?.handleLogout()
    }
}


