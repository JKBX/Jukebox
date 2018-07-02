//
//  CustomPartyImage.swift
//  Jukebox
//
//  Created by Maximilian Babel on 30.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation
import UIKit

class customPartyImage: UIImageView {
    override func setNeedsLayout() {
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
