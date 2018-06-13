//
//  TrackModel.swift
//  Jukebox
//
//  Created by Philipp on 06.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//
import FirebaseDatabase
import FirebaseAuth


class TrackModel{
    
    var trackId: String!
    var songName: String!
    var artist: String!
    var album: String!
    var coverUrl: URL!
    var voteCount: UInt!
    var liked: Bool
    
    init(from snapshot: DataSnapshot){
        let userId = Auth.auth().currentUser?.uid as! String
        
        self.trackId = snapshot.key
        self.songName = snapshot.childSnapshot(forPath: "songTitle").value as! String
        self.artist = snapshot.childSnapshot(forPath: "artist").value as! String
        self.album = snapshot.childSnapshot(forPath: "albumTitle").value as! String
        self.coverUrl = URL(string: snapshot.childSnapshot(forPath: "coverURL").value as! String)!
        self.liked = snapshot.childSnapshot(forPath: "votes/\(userId)").exists()
        self.voteCount = snapshot.childSnapshot(forPath: "votes").childrenCount
    }
}
