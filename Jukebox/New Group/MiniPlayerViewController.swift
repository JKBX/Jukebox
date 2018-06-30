//
//  MiniPlayerViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 12.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Kingfisher
import MarqueeLabel
import Firebase


class MiniPlayerViewController: UIViewController{

    // MARK: Properties
    
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var broadcastingButton: UIButton!
    var timer: Timer!
    
    var delegate: PlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()

        swipeUpGesture()
        marqueeLabelMiniPlayer(MarqueeLabel: artist)
        marqueeLabelMiniPlayer(MarqueeLabel: songTitle)
        userTriggeredButton(isAdmin: currentAdmin)
        timer = Timer.init()
        playPauseButton()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        playPause.adjustsImageWhenHighlighted = false
  
    }
    
    @IBAction func Play(_ sender: Any) {
        print("test PLAY")
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.toggle, object: nil)
    }
 
    @IBAction func broadcast(_ sender: Any) {
        
        if(!isBroadcasting){
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.startBroadcast, object: nil)
            broadcastingButton.setImage(UIImage(named: "baseline_volume_off_white_36pt"), for: .normal)
        }else{
//            Bild nur ändern wenn der playbackstatus sich auch geändert hat, also via observer & isPlaying & isBroadcasting
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.stopBroadcast, object: nil)
            broadcastingButton.setImage(UIImage(named: "baseline_volume_up_white_36pt"), for: .normal)
            
        }
        isBroadcasting = !isBroadcasting
    }
    
}

extension MiniPlayerViewController{

    func marqueeLabelMiniPlayer(MarqueeLabel label: MarqueeLabel){
        label.type = .continuous
        label.speed = .duration(10)
        label.trailingBuffer = 50
        label.fadeLength = 5.0
    }
    
    func update() {
        if(currentTrack != nil){
            updateProgressBar()
            setting()} else{ return}
      
        //TODO update track title album artist image
    }
    
    func updateProgressBar() {
        
        if (currentTrack?.isPlaying)!{
            resetTimer()
            let duration:Float = Float((currentTrack?.duration)!)
            let delay = NSDate.timeIntervalSinceReferenceDate - (currentTrack?.playbackStatus?.time)!
            var elapsed: Float =  Float(((currentTrack?.playbackStatus?.position)! + delay) * 1000)
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                self.progressView.setProgress(elapsed/duration, animated: true)
                elapsed += 100
            })
        } else {
            resetTimer()
        }
    }
    
    func resetTimer() {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }
    
    func setting(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        if let song = currentTrack {
            self.songTitle.text = song.songName
            self.artist.text = song.artist
            self.thumbImage.kf.indicatorType = .activity
            self.thumbImage.kf.setImage(with: song.coverUrl, placeholder: UIImage(named: "SpotifyLogoWhite"))
            
        }else {
            //TODO Handle no song in playing yet
            self.songTitle.text = "Weclome!"
            self.artist.text = "Awaiting a song to be in the playlist! Please add a song!"
           self.thumbImage.image = UIImage(named: "SpotifyLogoWhite")
        }
        }}
}

extension MiniPlayerViewController{
    
    @IBAction func tapGesturee(_ sender: Any) {
        if ((currentTrack != nil) && (currentAdmin || isBroadcasting)) {
            delegate?.expandSong()
        }
    }
    func swipeUpGesture(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action : #selector(swipeGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        self.view.isUserInteractionEnabled = true
    }
    
    @objc func swipeGesture(){
        if ((currentTrack != nil) && (currentAdmin || isBroadcasting)) {
            delegate?.expandSong()
        }
    }
}

extension MiniPlayerViewController: ExpandedTrackSourceProtocol{
    
    var frameInWindow: CGRect {
        let windowRect = view.convert(view.frame, to: nil)
        return windowRect
    }
    var coverImageView: UIImageView {
        
        return thumbImage
        
    }
    
//    trigger Admin or User
    func userTriggeredButton(isAdmin: Bool){
        
        playPause.isHidden = !isAdmin
        broadcastingButton.isHidden = isAdmin
        broadcastingButton.isEnabled = !isAdmin
    }
 
    func playPauseButton(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.trackChanged, object: nil, queue: nil) { (note) in
            if(currentTrack == nil){self.playPause.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)
                return
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.playPause.alpha = 0.3
            }, completion: {(finished) in
                if(currentTrack?.isPlaying)!{
                    self.playPause.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
                }else{
                    self.playPause.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)
                }
                UIView.animate(withDuration: 0.2, animations:{
                    self.playPause.alpha = 1.0
                },completion:nil)
            })
        }
    }
}


 


