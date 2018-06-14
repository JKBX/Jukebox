//
//  MiniPlayerViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 12.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Kingfisher

protocol MiniPlayerDelegate: class {
    func expandSong(song: Track)
}


class MiniPlayerViewController: UIViewController, SongSubscriber{

    // MARK: Properties
    
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playButton: UIButton!
    var isPlaying: Bool = false
    
    
//    MARK https://stackoverflow.com/questions/18793469/animate-a-point-of-a-bezier-curve --> var path: UIBezierPath
//    chevron transition
    
    
    var currentSong: Track?
    weak var delegate: MiniPlayerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting(song: nil)
        //TODO start party if no track playing
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func Play(_ sender: Any) {
        
        let play = NSNotification.Name.Spotify.playSong
        let pause = NSNotification.Name.Spotify.pauseSong
        NotificationCenter.default.post(name: isPlaying ? pause : play, object: nil)
        
    }
}

extension MiniPlayerViewController{
    
    func setting(song: Track?){
        if let song = song {
            songTitle.text = song.songName
            artist.text = song.artist
            thumbImage.kf.setImage(with: song.coverUrl)
        }else {
            songTitle.text = nil
            thumbImage.image = nil
        }
        currentSong = song
    }

}

extension MiniPlayerViewController{
    @IBAction func tapGesturee(_ sender: Any) {
        guard let song = currentSong else{
            return
        }
        delegate?.expandSong(song: song)
    }
}

extension MiniPlayerViewController:SPTAudioStreamingPlaybackDelegate{
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        songTitle.text = metadata.currentTrack?.name
        artist.text = metadata.currentTrack?.artistName
        thumbImage.kf.setImage(with: URL(string: (metadata.currentTrack?.albumCoverArtURL)!))
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        //TODO set ui position of track
        //print("Player Did change Position")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
         //print("Player Did change playback status")
        //TODO toggle play button design
        self.isPlaying = isPlaying
        print(self.isPlaying ? "Playing" : "Paused")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        //print("Player Did start playing track")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        //print("Player Did stop playing track")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) {
         print("Player Did change volume")
    }
    
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
         print("Player Did skip to next track")
    }
    
    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {
         print("Player Did skip to previous track")
    }
    
    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
         print("Player Did become active playback device")
    }
    
    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
         print("Player Did become inactive playback device")
    }
    
    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {
         print("Player Did lose permission")
    }
    
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
         print("Player Did pop queue")
    }
    
    
    // Mark - Unsupported Functions
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
        //Seeking will not be supported
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
        //Different Shufle Status will not be supported
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) {
        //Different Repeat modes will not be supported
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
        //Not Needed ???
        //print("Player Did Receive Playback Event")
    }
    
}
