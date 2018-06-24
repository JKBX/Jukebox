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

class SearchCell: UITableViewCell {
    
    //    var searchTrackImageView: UIImageView = {
    //        var imageView = UIImageView()
    //        imageView.translatesAutoresizingMaskIntoConstraints = false
    //        return imageView
    //    }()
    //
    //    var searchTrackName: UILabel = {
    //        var trackLabel = UILabel()
    //        trackLabel.translatesAutoresizingMaskIntoConstraints = false
    //        return trackLabel
    //    }()
    //
    //    var searchTrackArtist: UITextView = {
    //        var artistLabel = UITextView()
    //        artistLabel.translatesAutoresizingMaskIntoConstraints = false
    //        return artistLabel
    //    }()
    //
    //    var moreButton: UIButton = {
    //        var button = UIButton()
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //    }()
    //
    //    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
    //        super.init(style: style, reuseIdentifier: reuseIdentifier)
    //        self.addSubview(searchTrackImageView)
    //        self.addSubview(searchTrackName)
    //        self.addSubview(searchTrackArtist)
    //        self.addSubview(moreButton)
    //    }
    //
    //    override func layoutSubviews() {
    //
    //        searchTrackImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
    //        searchTrackImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    //        searchTrackImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    //        searchTrackImageView.widthAnchor.constraint(equalTo: self.searchTrackImageView.heightAnchor).isActive = true
    //
    //        searchTrackName.leftAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    //        searchTrackName.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
    //        searchTrackName.heightAnchor.constraint(equalToConstant: 21).isActive = true
    //        searchTrackName.rightAnchor.constraint(equalTo: moreButton.leftAnchor).isActive = true
    //
    //    }
    
    var track:TrackModel?
    var partyRef: DatabaseReference?
    var accessoryButton: UIButton = UIButton(frame: CGRect(x: 24, y: 24, width: 24, height: 24))
    
    func setup(from track:TrackModel) {
        self.track = track
        self.textLabel?.text = track.songName
        self.detailTextLabel?.text = "\(String(track.artist)) (\(String(track.album)))"
        self.heightAnchor.constraint(equalToConstant: 100).isActive = true
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })
        
        accessoryButton.setImage(UIImage(named: track.liked ? "addIconAcc" : "checkedButtonAcc"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(prepareAndAddToFirebase), for: .touchUpInside)
        self.accessoryView = accessoryButton
        
    }
    
    @objc func prepareAndAddToFirebase(){
        let userID = Auth.auth().currentUser?.uid
        var trackId = self.track?.trackId!
        let newTrack: NSDictionary = [
            "albumTitle": self.track?.album!,
            "artist" : self.track?.artist!,
            "coverURL" : self.track?.coverUrl!.absoluteString,
            "songTitle" : self.track?.songName!,
            "votes" : [
                "\(userID!)" : "true"
            ]
        ]
        self.partyRef?.child("/queue/\(trackId!)").setValue(newTrack)
    }
    
    //    @objc func checkForTrackInExistingPlaylist(trackId: String) {
    //        self.partyRef?.child("/queue").observeSingleEvent(of: .value, with: { (snapshot) in
    //            if snapshot.hasChild(trackId){
    //
    //            }else{
    //                print("false room doesn't exist")
    //            }
    //        })
    //    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.image = UIImage(named: "coverImagePlaceholder")
    }
}
