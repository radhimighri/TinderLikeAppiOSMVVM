//
//  SendMessageBtn.swift
//  TinderLikeApp
//
//  Created by Radhi Mighri on 02/11/2020.
//  Copyright © 2020 Radhi Mighri. All rights reserved.
//

import UIKit

class SendMessageBtn: UIButton {
    override func draw(_ rect: CGRect) {
         super.draw(rect)
        
        let gradientLayer = CAGradientLayer()
        let leftColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        let rightColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
        
        gradientLayer.colors = [leftColor.cgColor, rightColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        layer.cornerRadius = rect.height / 2
        clipsToBounds = true
                
        gradientLayer.frame = rect
    }
}
