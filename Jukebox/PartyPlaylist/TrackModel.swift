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
    var duration: Int!
    var isPlaying: Bool!
    var playbackStatus: (position: TimeInterval, time: TimeInterval, delay: TimeInterval?)?

    init(from snapshot: DataSnapshot){
        let userId = Auth.auth().currentUser?.uid as! String
        self.trackId = snapshot.hasChild("id") ? snapshot.childSnapshot(forPath: "id").value as! String : snapshot.key
        self.songName = snapshot.childSnapshot(forPath: "songTitle").value as! String
        self.artist = snapshot.childSnapshot(forPath: "artist").value as! String
        self.album = snapshot.childSnapshot(forPath: "albumTitle").value as! String
        self.coverUrl = URL(string: snapshot.childSnapshot(forPath: "coverURL").value as! String)!
        self.liked = snapshot.childSnapshot(forPath: "votes/\(userId)").exists()
        self.voteCount = snapshot.childSnapshot(forPath: "votes").childrenCount
        self.isPlaying = snapshot.hasChild("isPlaying") ? snapshot.childSnapshot(forPath: "isPlaying").value as! Bool : false
       /* if snapshot.hasChild("playbackStatus"){
            let playbackStatus = snapshot.childSnapshot(forPath: "playbackStatus")
            self.playbackStatus?.position = playbackStatus.childSnapshot(forPath: "position").value as! TimeInterval
            self.playbackStatus?.time = playbackStatus.ch
        }*/
        self.playbackStatus = snapshot.hasChild("playbackStatus") ?
            ((position: snapshot.childSnapshot(forPath: "playbackStatus/position").value,
              time: snapshot.childSnapshot(forPath: "playbackStatus/time").value,
              delay: snapshot.hasChild("playbackStatus/delay") ? snapshot.childSnapshot(forPath: "playbackStatus/delay").value : nil) 
                as! (position: TimeInterval, time: TimeInterval, delay: TimeInterval?)) : nil
        self.duration = snapshot.childSnapshot(forPath: "duration").value as! Int
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
        self.coverUrl = URL(string: (track.album.images.first?.url)!)
        self.liked = false
        self.voteCount = nil
        self.duration = track.durationMs
    }

    func isIn(_ queue: [TrackModel]) -> TrackModel? {
        for track in queue{
            if self.trackId == track.trackId {
                return track
            }
        }
        return nil
    }
}
