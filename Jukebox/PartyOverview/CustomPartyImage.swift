//
//  CustomPartyImage.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation

class customPartyImage: UIImageView {
    override func setNeedsLayout() {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width/2, y: self.frame.height/2))
        path.addLine(to: CGPoint(x: self.frame.width/2, y: self.frame.height))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height/2))

    }
}
