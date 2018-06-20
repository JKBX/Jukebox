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
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        self.addSubview(searchTrackImageView)
//        self.addSubview(searchTrackName)
//        self.addSubview(searchTrackArtist)
//        self.addSubview(moreButton)
//    }
    
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
    
    @IBOutlet weak var voteCountLabel: UILabel!
    
    func setup(from track:TrackModel) {
        self.track = track
        self.textLabel?.text = track.songName
        self.detailTextLabel?.text = "\(String(track.artist)) (\(String(track.album)))"
        self.imageView?.kf.setImage(with: track.coverUrl, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, URL) in
            self.setNeedsLayout()
        })
        
        let accessoryButton: UIButton = UIButton(frame: CGRect(x: 24, y: 24, width: 24, height: 24))
        accessoryButton.setImage(UIImage(named: track.liked ? "favorite" : "favoriteOutline"), for: .normal)
        accessoryButton.addTarget(self, action: #selector(addToFirebase), for: .touchUpInside)
        self.accessoryView = accessoryButton
        print(track.songName)
    }
    
    @objc func addToFirebase(){
        let userID = Auth.auth().currentUser?.uid
        let newTrack: NSDictionary = [
            "albumTitle": self.track?.album!,
            "artist" : "\(self.track?.artist!)",
            "coverURL" : "\(self.track?.coverUrl!)",
            "songTitle" : "\(self.track?.songName!)",
            "votes" : [
                "\(userID!)" : "true"
            ]
        ]
        self.partyRef?.child("/queue/\(track?.trackId!)").setValue(newTrack)
        
        
        
//        let userId = Auth.auth().currentUser?.uid as! String
//        let voteRef = self.partyRef?.child("/queue/\(track?.trackId as! String)/votes/\(userId as String)")
//        if (track?.liked)!{
//            //Unlike
//            voteRef?.removeValue()
//        } else {
//            //Like
//            voteRef?.setValue(true)
//        }
//        delegate?.likedTrack(trackID: trackID)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageView?.image = UIImage(named: "coverImagePlaceholder")
    }
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
