//
//  TrackCell.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.

import UIKit

protocol TrackCellDelegate{
    func likedTrack(trackID: String)
//    func showTrackOptions(trackID: String)
}

class TrackCell: UITableViewCell {

    var delegate: TrackCellDelegate?
    var trackID: String = ""
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
//    Labels tag order -> [Title,Artist,Counter] = [0,1,2]
    @IBOutlet var titleArtistCounterLabels: [UILabel]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func tappedLikeButton(_ sender: UIButton) {
        delegate?.likedTrack(trackID: trackID)
    }
}
