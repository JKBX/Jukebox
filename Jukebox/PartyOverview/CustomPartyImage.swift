//
//  CustomPartyImage.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation
import UIKit

class CustomPartyImage: UIImageView {
    
    
    
    override func setNeedsLayout() {
//        super.setNeedsLayout()
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: self.frame.width/2, y: self.frame.height/2))
        path.addLine(to: CGPoint(x: self.frame.width/2, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height/2))
        path.addLine(to: .zero)
        
        path.close()
        UIColor.red.setFill()
        path.stroke()
        path.reversing()
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.red.cgColor
        self.layer.mask = shapeLayer;
        self.layer.masksToBounds = true;
    }
}
