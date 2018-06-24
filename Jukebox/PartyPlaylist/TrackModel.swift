//
//  TrackModel.swift
//  Jukebox
//
//  Created by Philipp on 06.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//
import FirebaseDatabase
import FirebaseAuth
import Spartan


class TrackModel{
    
    var trackId: String!
    var songName: String!
    var artist: String!
    var album: String!
    var coverUrl: URL!
    var voteCount: UInt!
    var liked: Bool
    var duration: UInt!
    
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
    init(from track: Track) {
        self.trackId = track.id as! String
        self.songName = track.name as! String
        self.artist = ""
        for artist in track.artists{
            self.artist.append("\(artist.name!), ")
        }
        self.artist.removeLast(2)
        self.album = track.album.name as! String
        self.coverUrl = URL(string: (track.album.images.last?.url)!)
        self.liked = false
        self.voteCount = nil
    }
    
    func inIn(_ queue: [TrackModel]) -> TrackModel? {
        for track in queue{
            if self.trackId == track.trackId {
                return track
            }
        }
        return nil
    }
}
