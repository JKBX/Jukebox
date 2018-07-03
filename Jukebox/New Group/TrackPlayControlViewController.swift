//
//  TrackPlayControlViewController.swift
//  Jukebox
//
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import MarqueeLabel
import Firebase
import FirebaseDatabase

class TrackPlayControlViewController: UIViewController {
    
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var elapsed: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var position: UISlider!
    var timer: Timer!
    var nextSwitch:Bool = true
    var triggerPlayNext:Bool = true

    
    override func viewDidLoad() {
        super.viewDidLoad()
        marqueeLabelTrackPlayer(MarqueeLabel: songTitle)
        marqueeLabelTrackPlayer(MarqueeLabel: artist)
        setFields()
        updateDuration()
        setupPositionSlider()
        /* Alternaitve positioning
        playPause()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.trackChanged, object: nil, queue: nil) { (note) in
            self.setFields()
            if self.nextSwitch {self.playPause()}
            self.updateDuration()
        }*/
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.trackChanged, object: nil, queue: nil) { (note) in
            self.setFields()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.position, object: nil, queue: nil) { (note) in
            self.updateDuration()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.isPlay, object: nil, queue: nil) { (note) in
            self.playPause()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playPauseButton.isHidden = !currentAdmin
        previousButton.isHidden = !currentAdmin
        nextButton.isHidden = !currentAdmin
        
        //Streaming Positioning
        setPlayPause()
   }
    
    @IBAction func playButton(_ sender: Any) {
        AudioServicesPlaySystemSound(1520)
        nextSwitch = true
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.toggle, object: nil)
    }
    
    @IBAction func previousButton(_ sender: Any) {
        AudioServicesPlaySystemSound(1519)
        nextSwitch = false
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.prevSong, object: nil)
        
        //Streaming Positioning
        elapsed.text = "00:00"
        //TODO set duration & progress bar
    }
    
    @IBAction func nextButton(_ sender: Any) {
        AudioServicesPlaySystemSound(1521)
        nextButton.isEnabled = false
        nextSwitch = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.nextSong, object: nil)
            self.nextButton.isEnabled = true
            self.elapsed.text = "00:00"
            self.duration.text = ""
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

    // Start: positioning via streaming
    func playPause () {
        if(currentTrack == nil){return}
        if(nextSwitch)
        {UIView.animate(withDuration: 0.3, animations: {
            self.playPauseButton.alpha = 0.3
        }, completion: {(finished) in
            if(currentTrack?.isPlaying)!{
                self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                self.playPauseButton.setImage(UIImage(named: "pausePressed"), for: .highlighted)
            }else{
                self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                self.playPauseButton.setImage(UIImage(named: "playPressed"), for: .highlighted)
            }
            UIView.animate(withDuration: 0.2, animations:{
                self.playPauseButton.alpha = 1.0
            },completion:nil)
        })}
        
    }
    
    func setPlayPause(){
        if((currentTrack?.isPlaying)!){
            self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
            self.playPauseButton.setImage(UIImage(named: "pausePressed"), for: .highlighted)
        }else{
            self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
            self.playPauseButton.setImage(UIImage(named: "playPressed"), for: .highlighted)
        }
    }
    
    func updateDuration() {
        if(currentAdmin){
            
            var durationTime: String{
                let formatter = DateFormatter()
                formatter.dateFormat = "mm:ss"
                let date = Date(timeIntervalSince1970: currentTrackPosition)
                return formatter.string(from: date)
            }
            
            self.elapsed.text = durationTime
            //TODO set duration & progress bar
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
                        let date = Date(timeIntervalSince1970: position)
                        return formatter.string(from: date)
                    }
                    
                    self.elapsed.text = durationTime
                    //TODO set duration & progress bar
                    
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
    
    /* Alternative positioning with timers
     func playPause () {
        if let currentTrack = currentTrack{
            if currentTrack.isPlaying{
                self.playPauseButton.setImage(UIImage(named: "pause"), for: .normal)
                self.playPauseButton.setImage(UIImage(named: "pausePressed"), for: .highlighted)
            }else{
                self.playPauseButton.setImage(UIImage(named: "play"), for: .normal)
                self.playPauseButton.setImage(UIImage(named: "playPressed"), for: .highlighted)
            }
        }
    }

    func updateDuration() {
        if let currentTrack = currentTrack {
            if currentTrack.isPlaying {
                resetTimer()
                guard let status = currentTrack.playbackStatus else { return }
                let duration = floor(TimeInterval(currentTrack.duration) / 1000)
                var elapsed = (status.position + NSDate.timeIntervalSinceReferenceDate - status.time)
                timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                    let position = self.getDurationData(duration: duration, elapsed: elapsed)
                    self.elapsed.text = position.elapsed
                    self.duration.text = position.duration
                    self.position.setValue(position.position, animated: true)
                    elapsed += 0.1
                })
            } else {
                print("Else")
                resetTimer()
                guard let status = currentTrack.playbackStatus else { return }
                let duration = floor(TimeInterval(currentTrack.duration) / 1000)
                let elapsed = (status.position + NSDate.timeIntervalSinceReferenceDate - status.time)
                let position = self.getDurationData(duration: duration, elapsed: elapsed)
                self.elapsed.text = position.elapsed
                self.duration.text = position.duration
                self.position.setValue(position.position, animated: true)
            }
        }
    }
    
    func getDurationData(duration: TimeInterval, elapsed: TimeInterval)
        -> (elapsed: String, duration: String, position: Float) {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        let elapsedDate = Date(timeIntervalSince1970: floor(elapsed))
        let durationDate = Date(timeIntervalSince1970: duration - floor(elapsed))
        return (elapsed: formatter.string(from: elapsedDate),
                duration: "-\(formatter.string(from: durationDate))",
                position: Float(elapsed/duration) )
    }
    
    func resetTimer() {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }*/
    
    
    func setupPositionSlider(){
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 8, height: 8), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()
        let rect = CGRect(x: 0, y: 0, width: 8, height: 8)
        ctx.setFillColor((UIColor(named: "SolidGrey50")?.cgColor)!)
        ctx.fillEllipse(in: rect)
        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        position.setThumbImage(img, for: .normal)
    }
}
