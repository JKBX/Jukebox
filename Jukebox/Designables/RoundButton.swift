//
//  RoundButton.swift
//  Jukebox
//
//  Created by Maximilian Babel on 05.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class ButtonDesignable: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
