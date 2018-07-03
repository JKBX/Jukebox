//
//  MiniPlayerViewController.swift
//  Jukebox
//
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Kingfisher
import MarqueeLabel
import Firebase
import FirebaseDatabase


class MiniPlayerViewController: UIViewController{


    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var broadcastingButton: UIButton!
    var timer: Timer!
    var triggerSpotifyLogin: Bool = true

    var delegate: PlayerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setting()
        isLoggedInSpotify()
        swipeUpGesture()
        marqueeLabelMiniPlayer(MarqueeLabel: artist)
        marqueeLabelMiniPlayer(MarqueeLabel: songTitle)
        userTriggeredButton(isAdmin: currentAdmin)
        timer = Timer.init()
        lastSongPlayed()
        newTrackViaSearch()
        setBroadcastingUpdateImage()
    }

    override func viewWillAppear(_ animated: Bool) {
        playPause.adjustsImageWhenHighlighted = false

        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.broadcast, object: nil, queue: nil) { (_) in
            print(broadcasting)
            switch broadcasting {
            case .active:
                print("active")
                self.broadcastingButton.isEnabled = true
                self.broadcastingButton.setImage(UIImage(named: "broadcastingActive"), for: .normal)
                self.broadcastingButton.setImage(UIImage(named: "broadcastingActivePressed"), for: .highlighted)
                
            case .updating:
                self.broadcastingButton.isEnabled = false
                
            case .inactive:
                print("inactive")
                self.broadcastingButton.isEnabled = true
                self.broadcastingButton.setImage(UIImage(named: "broadcastingInactive"), for: .normal)
                self.broadcastingButton.setImage(UIImage(named: "broadcastingInactivePressed"), for: .highlighted)
            }
        }
    }

    @IBAction func Play(_ sender: Any) {

        if(SPTAudioStreamingController.sharedInstance().loggedIn){
            triggerSpotifyLogin = true
            AudioServicesPlaySystemSound(1520)
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.toggle, object: nil)
        }else{
            playPause.isEnabled = false
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.loggedOut, object: nil)}
        }




    @IBAction func broadcast(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.broadcast, object: nil)
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
            updatePlayButton()
            setting()
            triggerSpotifyLogin = true
            }
        else{ return}
    }

    func updateProgressBar() {

        if (currentTrack?.isPlaying)!{
            resetTimer()
            progressView.isHidden = false
            let duration:Float = Float((currentTrack?.duration)!)
            let delay = NSDate.timeIntervalSinceReferenceDate - (currentTrack?.playbackStatus?.time)!
            var elapsed: Float =  Float(((currentTrack?.playbackStatus?.position)! + delay) * 1000)
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
                self.progressView.setProgress(elapsed/duration, animated: true)
                elapsed += 100
            })
        } else {
            resetTimer()
            let duration:Float = Float((currentTrack?.duration)!)
            let delay = NSDate.timeIntervalSinceReferenceDate - (currentTrack?.playbackStatus?.time)!
            let elapsed: Float =  Float(((currentTrack?.playbackStatus?.position)! + delay) * 1000)
            self.progressView.setProgress(elapsed/duration, animated: true)
        }
    }

    func resetTimer() {
        if timer != nil{
            timer.invalidate()
            timer = nil
        }
    }

    func setting(){

        if let song = currentTrack {
            self.songTitle.text = song.songName
            self.artist.text = song.artist
            self.thumbImage.kf.indicatorType = .activity
            self.thumbImage.kf.setImage(with: song.coverUrl, placeholder: UIImage(named: "SpotifyLogoWhite"))

        }else {
            self.songTitle.text = "Weclome!"
            self.artist.text = "Awaiting a song to be in the playlist! Please add a song!"
            self.thumbImage.image = UIImage(named: "SpotifyLogoWhite")
        }

    }
}

extension MiniPlayerViewController{

    @IBAction func tapGesturee(_ sender: Any) {
        if ((currentTrack != nil) && (currentAdmin || broadcasting == .active) && triggerSpotifyLogin) {
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
        if ((currentTrack != nil) && (currentAdmin || broadcasting == .active) && triggerSpotifyLogin) {
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
    func isLoggedInSpotify(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Spotify.loggedOut, object: nil, queue: nil) { (note) in
            self.songTitle.text = "SPOTIFY LOGGED OUT"
            self.artist.text = "Please refresh your Login!"
            self.triggerSpotifyLogin = SPTAudioStreamingController.sharedInstance().loggedIn
            self.playPause.isEnabled = self.triggerSpotifyLogin
            self.thumbImage.image = UIImage(named: "SpotifyLogoWhite")
            }}
    }

    func updatePlayButton(){
        self.triggerSpotifyLogin = true
        if let currentTrack = currentTrack{
            if currentTrack.isPlaying{
                self.playPause.setImage(UIImage(named: "pause"), for: .normal)
                self.playPause.setImage(UIImage(named: "pausePressed"), for: .highlighted)
            }else{
                self.playPause.setImage(UIImage(named: "play"), for: .normal)
                self.playPause.setImage(UIImage(named: "playPressed"), for: .highlighted)
            }
        } else{
            self.playPause.setImage(UIImage(named: "play"), for: .normal)
            self.playPause.setImage(UIImage(named: "playPressed"), for: .highlighted)
        }
    }
    
    func lastSongPlayed(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.lastSong, object: nil, queue: nil) { (note) in
            self.songTitle.text = "Last Song! Add Songs!"
            self.artist.text = "Thanks"
            self.triggerSpotifyLogin = false
            self.thumbImage.image = UIImage(named: "SpotifyLogoWhite")
            self.progressView.isHidden = true
            triggerLastSong = false
            self.playPause.isEnabled = false
            currentTrack?.isPlaying = false
            currentTrack = nil
        }
    }
    func newTrackViaSearch (){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Player.searchNewTrack, object: nil, queue: nil) { (note) in
            self.playPause.isEnabled = true
            triggerLastSong = true
            self.playPause.setImage(UIImage(named: "play"), for: .normal)

        }

    }
    
    func setBroadcastingUpdateImage() {
        let images: [UIImage] = [UIImage(named: "broadcastingUpdate1")!,UIImage(named: "broadcastingUpdate2")!,UIImage(named: "broadcastingUpdate3")!]
        self.broadcastingButton.setImage(UIImage.animatedImage(with: images, duration: 1.0), for: UIControlState.disabled)
    }
    
}
