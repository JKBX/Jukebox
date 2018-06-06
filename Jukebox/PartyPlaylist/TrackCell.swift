//
//  TrackCell.swift
//  Jukebox
//
//  Created by Maximilian Babel on 29.05.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

protocol TrackCellDelegate{
    func likedTrack(trackID: String)
//    func showTrackOptions(trackID: String)
}

class TrackCell: UITableViewCell {

    var delegate: TrackCellDelegate?
    var trackID: String = ""
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var songArtistLabel: UILabel!
    @IBOutlet weak var voteCounterLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func tappedLikeButton(_ sender: UIButton) {
        delegate?.likedTrack(trackID: trackID)
    }
}
