//
//  DesignableView.swift
//  Jukebox
//
//  Created by Maximilian Babel on 27.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

@IBDesignable class DesignableView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }
}
