//
//  MatchView.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 02/11/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

protocol MatchViewDelegate: class {
    func matchView(_ view: MatchView, wantsToSendMessageTo user: User)
}

class MatchView: UIView {
    
    //MARK:- Properties
    
    weak var delegate: MatchViewDelegate?
    
    private let viewModel: MatchViewViewModel
    private let matchImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    
    private let currentUserImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "lady5c"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()
    
    private let matchedUserImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "jane1"))
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.borderWidth = 2
        iv.layer.borderColor = UIColor.white.cgColor
        return iv
    }()
    
    private let sendMessageBtn: SendMessageBtn = {
        let btn = SendMessageBtn(type: .system)
        btn.setTitle("SEND MESSAGE", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(didTapSendMessage), for: .touchUpInside)
        return btn
    }()
    
    private let keepSwipingBtn: KeepSwipingBtn = {
        let btn = KeepSwipingBtn(type: .system)
        btn.setTitle("KEEP SWIPING", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return btn
    }()
    
    let backgroundVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    lazy var views = [matchImageView,
                      descriptionLabel,
                      currentUserImageView,
                      matchedUserImageView,
                      sendMessageBtn,
                      keepSwipingBtn
                     ]
    
    //MARK:- LifeCycle

    init(viewModel: MatchViewViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        load2UsersData()
        
        configureBlurView()
        configureUI()
        configureAnimations()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK:- Actions (#Selectors)
    
    @objc func didTapSendMessage() {
        delegate?.matchView(self, wantsToSendMessageTo: viewModel.matchedUser)
    }
    
    @objc func handleDismissal() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.alpha = 0
        }) { _ in
            self.removeFromSuperview()
        }
    }
    
    
    //MARK:- Helper Functions
    
    func load2UsersData() {
        
        descriptionLabel.text = viewModel.matchLabelText
        currentUserImageView.sd_setImage(with: viewModel.currentUserImageURL)
        matchedUserImageView.sd_setImage(with: viewModel.matchedUserImageURL)

    }
    
    func configureUI() {
        views.forEach { view in
            addSubview(view)
            view.alpha = 0
        }
        
        currentUserImageView.anchor(right: centerXAnchor, paddingRight: 16) //center left
        currentUserImageView.setDimensions(height: 140, width: 140)
        currentUserImageView.layer.cornerRadius = 140 / 2
        currentUserImageView.centerY(inView: self)
        
        matchedUserImageView.anchor(left: centerXAnchor, paddingLeft: 16)
        matchedUserImageView.setDimensions(height: 140, width: 140)
        matchedUserImageView.layer.cornerRadius = 140 / 2
        matchedUserImageView.centerY(inView: self)

        sendMessageBtn.anchor(top: currentUserImageView.bottomAnchor, left: leftAnchor,
                              right: rightAnchor, paddingTop: 32, paddingLeft: 48, paddingRight: 48)
        sendMessageBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        keepSwipingBtn.anchor(top: sendMessageBtn.bottomAnchor, left: leftAnchor,
                              right: rightAnchor, paddingTop: 16, paddingLeft: 48, paddingRight: 48)
        keepSwipingBtn.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        descriptionLabel.anchor(left: leftAnchor, bottom: currentUserImageView.topAnchor,
                              right: rightAnchor, paddingBottom: 32)
        
        matchImageView.anchor(bottom: descriptionLabel.topAnchor, paddingTop: 16)
        matchImageView.setDimensions(height: 80, width: 300)
        matchImageView.centerX(inView: self)
        
    }
    
    func configureBlurView() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissal))
        backgroundVisualEffectView.addGestureRecognizer(tap)
        
        addSubview(backgroundVisualEffectView)
        backgroundVisualEffectView.fillSuperview()
        backgroundVisualEffectView.alpha = 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.backgroundVisualEffectView.alpha = 1
        }, completion: nil)
    }
    
    func configureAnimations() {
        views.forEach({ $0.alpha = 1 })
        
        let angle = 30 * CGFloat.pi / 100
        
        currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        
        matchedUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        
        self.sendMessageBtn.transform = CGAffineTransform(translationX: -500, y: 0)
        self.keepSwipingBtn.transform = CGAffineTransform(translationX: 500, y: 0)
        
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.matchedUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
            }

            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImageView.transform = .identity
                self.matchedUserImageView.transform = .identity
            }
        }, completion: nil)
        
        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.sendMessageBtn.transform = .identity
            self.keepSwipingBtn.transform = .identity
        }, completion: nil)
    }
    
    
}
