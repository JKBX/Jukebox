//
//  SearchCell.swift
//  Jukebox
//
//  Created by Maximilian Babel on 12.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

protocol SearchCellDelegate {
    func showSuccess() -> Void
}

class SearchCell: UITableViewCell {

    var track: TrackModel?
    var partyRef: DatabaseReference?
    var accessoryButton: UIButton = UIButton(frame: CGRect(x: 24, y: 24, width: 24, height: 24))
    var delegate: SearchCellDelegate?
    
    func setup(from track:TrackModel, delegate: SearchCellDelegate) {
        self.track = track
        self.textLabel?.text = track.songName
        self.delegate = delegate
        self.detailTextLabel?.text = "\(String(track.artist)) (\(String(track.album)))"
        self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })
        accessoryButton.setImage(UIImage(named: track.liked ? "checkedButtonAcc" : "addIconAcc"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(prepareAndAddToFirebase), for: .touchUpInside)
        
        self.accessoryView = accessoryButton
        
    }
    
    @objc func prepareAndAddToFirebase(){
        accessoryButton.setImage(UIImage(named: "checkedButtonAcc"), for: .normal)
        NotificationCenter.default.post(name: NSNotification.Name.isEditing, object: nil)

        let userID = Auth.auth().currentUser?.uid
        var trackId = self.track?.trackId!
        let ref = Database.database().reference().child("/parties/\(currentParty)/queue/\(trackId!)")
        let newTrack: NSDictionary = [
            "albumTitle": self.track?.album!,
            "artist" : self.track?.artist!,
            "coverURL" : self.track?.coverUrl!.absoluteString,
            "songTitle" : self.track?.songName!,
            "duration": self.track?.duration!,
            "votes" : [
                "\(userID!)" : "true"
            ]
        ]
        ref.setValue(newTrack) { (e, _) in
            if e == nil {
                self.delegate?.showSuccess()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.image = UIImage(named: "coverImagePlaceholder")
    }
}
