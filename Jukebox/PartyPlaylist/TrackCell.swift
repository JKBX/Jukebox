//
//  TrackCell.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
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

    var track: TrackModel?
    var label: UILabel?
    var partyRef: DatabaseReference?

    @IBOutlet weak var voteCountLabel: UILabel!

    func setup(from track:TrackModel) {
        self.track = track
        self.textLabel?.text = track.songName
        //self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.detailTextLabel?.text = "\(String(track.artist)) (\(String(track.album)))"
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })

        label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width - 48, y: 40, width: 32, height: 24))
        label!.text = String(track.voteCount)
        label!.textAlignment = .right
        label!.textColor = .white
        label!.font.withSize(8)
        label!.backgroundColor = UIColor(named: "SolidGrey800")

        self.contentView.addSubview(label!)

        let accessoryButton: UIButton = UIButton(frame: CGRect(x: 24, y: 24, width: 24, height: 24))
        accessoryButton.setImage(UIImage(named: track.liked ? "favorite" : "favoriteOutline"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(toggleLike), for: .touchUpInside)

        self.accessoryView = accessoryButton
    }

    @objc func toggleLike(){
        let userId = Auth.auth().currentUser?.uid as! String
        let voteRef = self.partyRef?.child("/queue/\(track?.trackId as! String)/votes/\(userId as String)")
        if (track?.liked)!{
            print("Unliking")
            voteRef?.removeValue()
        } else {
            print("Liking")
            voteRef?.setValue(true)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.image = UIImage(named: "coverImagePlaceholder")
    }
}
