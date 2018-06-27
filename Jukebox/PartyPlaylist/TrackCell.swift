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
}

class TrackCell: UITableViewCell {
    
    //var delegate: TrackCellDelegate?
    //var trackID: String = ""
    var track:TrackModel?
    var partyRef: DatabaseReference?
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    func setup(from track:TrackModel) {
        self.track = track
        self.textLabel?.text = track.songName
        self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.detailTextLabel?.text = "\(String(track.artist)) (\(String(track.album)))"
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })
        
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 48, y: 40, width: 32, height: 24))
        label.text =  String(track.voteCount)//"I'am a test label"
        label.textAlignment = .right
        label.textColor = .white
        label.font.withSize(8)
        self.contentView.addSubview(label)
        
        //voteCountLabel.text = String(track.voteCount)
        
        let accessoryButton: UIButton = UIButton(frame: CGRect(x: 24, y: 24, width: 24, height: 24))
        accessoryButton.setImage(UIImage(named: track.liked ? "favorite" : "favoriteOutline"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)
        self.accessoryView = accessoryButton
        print(track.songName)
    }
    
    @objc func toggleLike(){
        
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

