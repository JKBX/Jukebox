//
//  PartyCollectionViewCell.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit

class PartyCollectionViewCell: UICollectionViewCell {
    
    var PartyID: String!
    var PartyHost: String!
    var cellPartyInfo: NSDictionary!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var PartyName: UILabel!
    @IBOutlet weak var Image: UIImageView!
    
    func setCellShadow(){
        Image.layer.cornerRadius = 5.0
        Image.layer.borderWidth = 1.0
        Image.layer.borderColor = UIColor.clear.cgColor
        Image.layer.masksToBounds = true
    }
}
