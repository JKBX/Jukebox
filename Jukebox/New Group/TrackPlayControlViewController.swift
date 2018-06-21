//
//  TrackPlayControlViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import MarqueeLabel

class TrackPlayControlViewController: UIViewController, TrackSubscriber {
    
    var currentSong: TrackModel?{
        didSet{
        setFields()
        }
    }
    
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var songDuration: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setFields()
        marqueeLabelTrackPlayer(MarqueeLabel: songTitle)
        marqueeLabelTrackPlayer(MarqueeLabel: artist)
    
    }
    override func viewWillAppear(_ animated: Bool) {
     
    }
    
    @IBAction func playButton(_ sender: Any) {
     
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
        var durationTime: String{
            let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"
            let date = Date(timeIntervalSince1970: metadata.currentTrack!.duration)
            return formatter.string(from: date)
        }
        print("func call audioStreaming in TrackPlayController")
        songTitle.text = metadata.currentTrack?.name
        artist.text = metadata.currentTrack?.artistName
        songDuration.text = durationTime
    }
    
    }


    


