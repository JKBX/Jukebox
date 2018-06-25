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

class TrackPlayControlViewController: UIViewController {
    
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marqueeLabelTrackPlayer(MarqueeLabel: songTitle)
        marqueeLabelTrackPlayer(MarqueeLabel: artist)

        setFields()
        if((currentTrack?.isPlaying)!){
            playPauseButton.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playPauseButton.isHidden = !currentAdmin
        previousButton.isHidden = !currentAdmin
        nextButton.isHidden = !currentAdmin
    }
    
    @IBAction func playButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.toggle, object: nil)
        
    }
    
    @IBAction func previousButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.prevSong, object: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.nextSong, object: nil)
    }

}
extension TrackPlayControlViewController{
    func setFields(){
        //guard songTitle != nil else{ return } //Maybe causing errors :)
        songTitle.text = currentTrack?.songName
        artist.text = currentTrack?.artist
    }

    // Marquee settings
    func marqueeLabelTrackPlayer(MarqueeLabel label: MarqueeLabel){
        label.type = .continuous
        label.speed = .duration(10)
        label.trailingBuffer = 50
        label.fadeLength = 5.0
        label.isUserInteractionEnabled = false
    }
}



//extension TrackPlayControlViewController: SPTAudioStreamingPlaybackDelegate{
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
//        songTitle.text = metadata.currentTrack?.name
//        artist.text = metadata.currentTrack?.artistName
//    }
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
//        var durationTime: String{
//            let formatter = DateFormatter()
//            formatter.dateFormat = "mm:ss"
//            let date = Date(timeIntervalSince1970: position)
//            return formatter.string(from: date)
//        }
//        songDuration.text = durationTime
//
//    }
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
//        
//        UIView.animate(withDuration: 0.3, animations: {
//            self.playPauseButton.alpha = 0.3
//        }, completion: {(finished) in
//            if(currentTrack?.isPlaying)!{
//                self.playPauseButton.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
//            }else{
//                self.playPauseButton.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)
//            }
//            UIView.animate(withDuration: 0.2, animations:{
//                self.playPauseButton.alpha = 1.0
//            },completion:nil)
//        })
//    }
//    
//    
//    
//
//}
    


