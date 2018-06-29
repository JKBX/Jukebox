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
    var timer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marqueeLabelTrackPlayer(MarqueeLabel: songTitle)
        marqueeLabelTrackPlayer(MarqueeLabel: artist)
        setFields()
        durationSet()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.trackChanged, object: nil, queue: nil) { (note) in
            self.setFields()
            self.playPause()
        }
  
 }
    
    override func viewWillAppear(_ animated: Bool) {
        playPauseButton.isHidden = !currentAdmin
        previousButton.isHidden = !currentAdmin
        nextButton.isHidden = !currentAdmin
        setPlayPause()
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
        
        
    func durationSet(){
        
        if (timer == nil) && (currentTrack?.isPlaying)! {
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                
                print("TEstest")
                
            })
        }else{
            resetTimer()
        }
    }
    
    func resetTimer() {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    
    
    func playPause () {
        UIView.animate(withDuration: 0.3, animations: {
            self.playPauseButton.alpha = 0.3
        }, completion: {(finished) in
            if(currentTrack?.isPlaying)!{
                self.playPauseButton.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
            }else{
                self.playPauseButton.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)
            }
            UIView.animate(withDuration: 0.2, animations:{
                self.playPauseButton.alpha = 1.0
            },completion:nil)
        })
    }
    func setPlayPause(){
        if((currentTrack?.isPlaying)!){
            playPauseButton.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
        }else{playPauseButton.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)}
    }
//timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
//    var durationTime: String{
//        let formatter = DateFormatter()
//        formatter.dateFormat = "mm:ss"
//        let date = Date(timeIntervalSince1970: position!)
//        return formatter.string(from: date)
//    }
//
//    self.songDuration.text = durationTime

}




