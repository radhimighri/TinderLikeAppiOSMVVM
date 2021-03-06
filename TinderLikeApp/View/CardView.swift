//
//  CardView.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 27/10/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit
import SDWebImage

//we shouldn't put the API funcs inside Views so thats why we use those delegate methods
protocol CardViewDelegate: class {
    func cardView(_ view: CardView, wantsToShowProfileFor user: User)
    func cardView(_ view: CardView, didLikeUser: Bool)
}
enum SwipeDirection: Int {
    case left = -1
    case right = 1
}

class CardView: UIView {
    
    //MARK:- Properties
    weak var delegate: CardViewDelegate?
    
    private let gradientLayer = CAGradientLayer()
    private lazy var barStackView = SegmentedBarView(numberOfSegments: viewModel.imageURLs.count)
    let viewModel: CardViewModel
    
    private let imageView: UIImageView = {
      let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.attributedText = viewModel.userInfoText
        return label
    }()
    
    
    private lazy var infoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "info_icon").withRenderingMode(.alwaysOriginal) , for: .normal)
        button.addTarget(self, action: #selector(handleShowProfile), for: .touchUpInside)
        return button
    }()
    
     init(viewModel: CardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
//        print("DEBUG: Did init..")
        configureGestureRecognizers()
        
        imageView.sd_setImage(with: viewModel.imageUrl)
        
        backgroundColor = .white
        layer.cornerRadius = 10
        clipsToBounds = true
        
        addSubview(imageView)
        imageView.fillSuperview()
        
        configureBarStackView()
        // adding the gradient layer before adding the info label
        configureGradientLayer()
        
        addSubview(infoLabel)
        infoLabel.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor,
                         paddingLeft: 16, paddingBottom: 16, paddingRight: 16)
        
        addSubview(infoButton)
        infoButton.setDimensions(height: 40, width: 40)
        infoButton.centerY(inView: infoLabel)
        infoButton.anchor(right: rightAnchor, paddingRight: 16)
    }
    
    override func layoutSubviews() {
//        print("DEBUG: Did laout Subviews")
        gradientLayer.frame = self.frame
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- Actions (Selectors)
    
    @objc func handleShowProfile() {
        delegate?.cardView(self, wantsToShowProfileFor: viewModel.user)
    }
    
    @objc func handlePanGesture(sender: UIPanGestureRecognizer) {
        switch sender.state {
        
        case .began:
//            print("DEBUG: Pan did begin..")
            superview?.subviews.forEach({ $0.layer.removeAllAnimations() })
        case .changed:
//            print("DEBUG: Pan did changed..")
            panCard(sender: sender)
        case .ended:
            print("DEBUG: Pan did ended..")
            resetCardPosition(sender: sender)
        default:
            break
        }

    }
    
    @objc func handleChangePhoto(sender: UITapGestureRecognizer) {
//        print("DEBUG: Did tap on photo..")

        let location = sender.location(in: nil).x
        let shouldShowNextPhoto = location > self.frame.width / 2
//        print("DEBUG: Location is \(location)")
//        print("DEBUG: Threshold value is \(self.frame.width / 2)")
//        print("DEBUG: Should show next photo is :  \(shouldShowNextPhoto)")
        if shouldShowNextPhoto {
            viewModel.showNextPhoto()
        } else {
            viewModel.showPreviousPhoto()
        }
        
//        imageView.image = viewModel.imageToShow
        imageView.sd_setImage(with: viewModel.imageUrl)
        
        //before using the SegmentedBarView :
//        barStackView.arrangedSubviews.forEach ({ $0.backgroundColor = .barDeselectedColor })
//        barStackView.arrangedSubviews[viewModel.index].backgroundColor = .white
        
        //after using the SegmentedBarView :
        barStackView.setHighlighted(index: viewModel.index)
    }
    
    //MARK:- Helpers Functions
    
    func panCard(sender: UIPanGestureRecognizer) {
                let transition = sender.translation(in: nil)
        //        print("DEBUG: Translation X is \(transition.x)")
        //        print("DEBUG: Translation Y is \(transition.y)")

        let degrees: CGFloat = transition.x / 20
        let angle = degrees * .pi / 180
        let rotationalTransform = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationalTransform.translatedBy(x: transition.x, y: transition.y)
    }

    func resetCardPosition(sender: UIPanGestureRecognizer) {
        
        let direction: SwipeDirection = sender.translation(in: nil).x > 100 ? .right : .left
        let shouldDismissCard = abs(sender.translation(in: nil).x) > 100
        
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            
            if shouldDismissCard {
                let xTranslation = CGFloat(direction.rawValue) * 1000
                let offScreenTransform = self.transform.translatedBy(x: xTranslation, y: 0)
                self.transform = offScreenTransform
            } else {
                self.transform = .identity
            }
            
        }) { _ in
//            print("DEBUG: Animation did complete..")
            if shouldDismissCard {
                let didLike = direction == .right //if .right : didLike : true, if .left:..false
                self.delegate?.cardView(self, didLikeUser: didLike)
            }
        }
    }
    
    func configureBarStackView() {
        //before using the SegmentedBarView :
//        (0..<viewModel.imageURLs.count).forEach { _ in
//            let barView = UIView()
//            barView.backgroundColor = .barDeselectedColor
//            barStackView.addArrangedSubview(barView)
//        }
//        barStackView.arrangedSubviews.first?.backgroundColor = .white
        
        addSubview(barStackView)
        barStackView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor,
                            paddingTop: 8, paddingLeft: 8, paddingRight: 8, height: 4)
//        barStackView.spacing = 4
//        barStackView.distribution = .fillEqually
    }
    
    func configureGradientLayer() {
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
            gradientLayer.locations = [0.5, 1.1]
        layer.addSublayer(gradientLayer)
    }
    
    func configureGestureRecognizers() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(pan)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleChangePhoto))
        addGestureRecognizer(tap)
    }
}
