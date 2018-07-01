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
import FirebaseDatabase

class TrackPlayControlViewController: UIViewController {
    
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    var timer: Timer!
    var nextSwitch:Bool = true
    var triggerPlayNext:Bool = true

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marqueeLabelTrackPlayer(MarqueeLabel: songTitle)
        marqueeLabelTrackPlayer(MarqueeLabel: artist)
        setFields()
        updateDuration()
    
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.trackChanged, object: nil, queue: nil) { (note) in
            self.setFields()
            self.playPause()
            self.nextButtonTrigger()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.position, object: nil, queue: nil) { (note) in
            self.updateDuration()
        }
        timer = Timer.init()
 }
    
    override func viewWillAppear(_ animated: Bool) {
        playPauseButton.isHidden = !currentAdmin
        previousButton.isHidden = !currentAdmin
        nextButton.isHidden = !currentAdmin
        nextButtonTrigger()

        setPlayPause()
   }
    
    @IBAction func playButton(_ sender: Any) {
        AudioServicesPlaySystemSound(1520)
        nextSwitch = true
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.toggle, object: nil)
    }
    
    @IBAction func previousButton(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        currentTrackPosition = 0
        songDuration.text = "00:00"
        nextSwitch = false
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.prevSong, object: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        AudioServicesPlaySystemSound(1521)
        if(!(currentTrack?.isPlaying)!){self.songDuration.text = "00:00"}
        nextButton.isEnabled = false
        nextSwitch = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.nextSong, object: nil)
            self.nextButton.isEnabled = true
        }
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

    func playPause () {
        if(currentTrack == nil){return}
        if(nextSwitch)
        {UIView.animate(withDuration: 0.3, animations: {
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
        })}
        
    }
    
    func setPlayPause(){
        if((currentTrack?.isPlaying)!){
            playPauseButton.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
        }else{playPauseButton.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)}
    }

    func updateDuration() {
        if(currentAdmin){
            
            var durationTime: String{
                let formatter = DateFormatter()
                formatter.dateFormat = "mm:ss"
                let date = Date(timeIntervalSince1970: currentTrackPosition)
                return formatter.string(from: date)
            }
            
            self.songDuration.text = durationTime
        }
        else{
            if(currentTrack == nil){return}
            if (currentTrack?.isPlaying)!{
                
                resetTimer()
                
                var position: TimeInterval = (currentTrack?.playbackStatus?.position)!
                
                timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
                
                var durationTime: String{
                    let formatter = DateFormatter()
                    formatter.dateFormat = "mm:ss"
                    let date = Date(timeIntervalSince1970: currentTrackPosition)
                    return formatter.string(from: date)
                }
                
                self.songDuration.text = durationTime
                
                            })
                        } else {
                            resetTimer()}
        } }
    
    func resetTimer() {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    
    func nextButtonTrigger(){
        if(currentQueue.count >= 1){self.nextButton.isEnabled = true}else{self.nextButton.isEnabled = false}
    }
    
        
    }
//
//    func currentPositionForFirebase(){
//        if(currentAdmin){let ref = Database.database().reference().child("/parties/\(currentParty)")
//            ref.child("/currentlyPlaying").child("isPosition").setValue(0.0)}
//        else{return}
//    }

    






