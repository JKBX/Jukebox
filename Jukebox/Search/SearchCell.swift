//
//  SearchCell.swift
//  Jukebox
//
//  Created by Maximilian Babel on 12.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchCell: UITableViewCell {
    
    var track:Track?
    var partyRef: DatabaseReference?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(from track:Track) {
        self.track = track
        self.textLabel?.text = track.songName
        self.detailTextLabel?.text = "\(String(track.artist)) (\(String(track.album)))"
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })
    }
}
