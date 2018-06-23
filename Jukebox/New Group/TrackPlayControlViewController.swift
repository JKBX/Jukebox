//
//  TrackPlayControlViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import MarqueeLabel
import Firebase

class TrackPlayControlViewController: UIViewController, TrackSubscriber {
    
    var currentSong: TrackModel?{
        didSet{
        setFields()
        }
    }
    var isAdmin: Bool!
    var isPlaying: Bool!
    
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    

    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid

    override func viewDidLoad() {
        super.viewDidLoad()
        setFields()
        marqueeLabelTrackPlayer(MarqueeLabel: songTitle)
        marqueeLabelTrackPlayer(MarqueeLabel: artist)
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        print("func call viewDidLoad TRACKPLAYCONTROLLER +" ,isPlaying)
        
    
    }
    override func viewWillAppear(_ animated: Bool) {
        playPauseButton.isHidden = false
        previousButton.isHidden = !isAdmin
        nextButton.isHidden = !isAdmin
        
        isPlaying = SPTAudioStreamingController.sharedInstance().playbackState.isPlaying
        
        
    }
    
    @IBAction func playButton(_ sender: Any) {
        
        let play = NSNotification.Name.Spotify.playSong
        let pause = NSNotification.Name.Spotify.pauseSong
        NotificationCenter.default.post(name: isPlaying ? pause : play, object: nil)
        
    }
    
    @IBAction func previousButton(_ sender: Any) {
        
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
    }

}
extension TrackPlayControlViewController{
    // important: songTitle is nil before
        func setFields(){
            guard songTitle != nil else{
                return
            }
            songTitle.text = currentSong?.songName
            artist.text = currentSong?.artist
        }
    }
    /*
     20.06.2018 - Chris
     
     Marquee settings
     */
    func marqueeLabelTrackPlayer(MarqueeLabel label: MarqueeLabel){
        label.type = .continuous
        label.speed = .duration(10)
        label.trailingBuffer = 50
        label.fadeLength = 5.0
        label.isUserInteractionEnabled = false
        
    }




extension TrackPlayControlViewController: SPTAudioStreamingPlaybackDelegate{
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        
        songTitle.text = metadata.currentTrack?.name
        artist.text = metadata.currentTrack?.artistName
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        var durationTime: String{
            let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"
            let date = Date(timeIntervalSince1970: position)
            return formatter.string(from: date)
        }
        songDuration.text = durationTime

    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        self.isPlaying = isPlaying
        
        print(self.isPlaying ? "Playing" : "Paused")
    }
    
    
    

}
    


