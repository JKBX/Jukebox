//
//  SearchCell.swift
//  Jukebox
//
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
        //self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })
        accessoryButton.setImage(UIImage(named: track.liked ? "checkedButtonAcc" : "addIconAcc"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(prepareAndAddToFirebase), for: .touchUpInside)
        
        self.accessoryView = accessoryButton
    }
    
    @objc func prepareAndAddToFirebase(){
        AudioServicesPlaySystemSound(1520)
        accessoryButton.setImage(UIImage(named: "checkedButtonAcc"), for: .normal)
        NotificationCenter.default.post(name: NSNotification.Name.isEditing, object: nil)

        let userID = Auth.auth().currentUser?.uid
        let trackId = self.track?.trackId!
        let ref = Database.database().reference().child("/parties/\(currentParty)/queue/\(trackId!)")
        let newTrack: NSDictionary = [
            "albumTitle": self.track?.album! as Any,
            "artist" : self.track?.artist! as Any,
            "coverURL" : self.track?.coverUrl!.absoluteString as Any,
            "songTitle" : self.track?.songName! as Any,
            "duration": self.track?.duration! as Any,
            "votes" : [
                "\(userID!)" : "true"
            ]
        ]
        ref.setValue(newTrack) { (e, _) in
            if e == nil {
                self.delegate?.showSuccess()
            }
        }
        if(!triggerLastSong){
            
            NotificationCenter.default.post(name: NSNotification.Name.Player.searchNewTrack, object: nil)}
        else{return}
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.image = UIImage(named: "coverImagePlaceholder")
    }
}
