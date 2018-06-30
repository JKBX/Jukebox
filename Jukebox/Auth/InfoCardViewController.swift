//
//  InfoCardViewController.swift
//  Jukebox
//
//  Created by Philipp on 21.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

class InfoCardViewController: UIViewController {
    
    var delegate: CardDelegate?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var picture: UIImageView!
    
    func update(_ user: User) {
        self.name.text = user.displayName
        self.username.text = user.uid
        if let image = user.photoURL {
            self.picture.kf.setImage(with: image)
        } else { self.picture.image = UIImage(named: "ProfilePictureDefault") }
        self.picture.layer.masksToBounds = true
        self.picture.layer.cornerRadius = 64.0
    }
    
    @IBAction func edit(_ sender: Any){
        self.delegate?.editing(true)
    }
}
