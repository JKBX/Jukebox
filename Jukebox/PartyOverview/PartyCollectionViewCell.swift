//
//  PartyCollectionViewCell.swift
//  Jukebox
//
//  Created by Philipp on 13.05.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit

class PartyCollectionViewCell: UICollectionViewCell {
    
    var PartyID: String!
    var PartyHost: String!
    var cellPartyInfo: NSDictionary!
    @IBOutlet weak var Label: UILabel!
    @IBOutlet weak var Image: UIImageView!
    
}
