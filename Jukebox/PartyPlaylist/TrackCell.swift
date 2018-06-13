//
//  TrackCell.swift
//  Jukebox
//
//  Created by Maximilian Babel on 29.05.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseAuth

protocol TrackCellDelegate{
    func likedTrack(trackID: String)
//    func showTrackOptions(trackID: String)
}

class TrackCell: UITableViewCell {

    //var delegate: TrackCellDelegate?
    //var trackID: String = ""
    var track:Track?
    var partyRef: DatabaseReference?

    @IBOutlet weak var voteCountLabel: UILabel!
    
    func setup(from track:Track) {
        self.track = track
        self.textLabel?.text = track.songName
        self.detailTextLabel?.text = "\(String(track.artist)) (\(String(track.album)))"
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })
        
        
        voteCountLabel.text = String(track.voteCount)
        
        let accessoryButton: UIButton = UIButton(frame: CGRect(x: 24, y: 24, width: 24, height: 24))
        accessoryButton.setImage(UIImage(named: track.liked ? "favorite" : "favoriteOutline"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)
        self.accessoryView = accessoryButton
    }
    
    @objc func toggleLike(){
        print("like")
        print(partyRef.debugDescription)
        let userId = Auth.auth().currentUser?.uid as! String
        let voteRef = self.partyRef?.child("/queue/\(track?.trackId as! String)/votes/\(userId as String)")
        if (track?.liked)!{
            //Unlike
            voteRef?.removeValue()
        } else {
            //Like
            voteRef?.setValue(true)
        }
        //delegate?.likedTrack(trackID: trackID)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.image = UIImage(named: "coverImagePlaceholder")
        // Initialization code
    }
}
