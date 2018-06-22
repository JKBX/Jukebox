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


protocol MiniPlayerDelegate: class {
    func expandSong(song: TrackModel)
}


class MiniPlayerViewController: UIViewController, TrackSubscriber{

    // MARK: Properties
    
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var playPause: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var partyID : String = ""
    var isAdmin: Bool = false
    
    
    var isPlaying: Bool = false

//    MARK https://stackoverflow.com/questions/18793469/animate-a-point-of-a-bezier-curve --> var path: UIBezierPath
//    chevron transition
    
    
    var currentSong: TrackModel?
    weak var delegate: MiniPlayerDelegate?
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting(song: nil)
        //TODO start party if no track playing
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        // Do any additional setup after loading the view.
        swipeUpGesture()
        marqueeLabelMiniPlayer(MarqueeLabel: artist)
        marqueeLabelMiniPlayer(MarqueeLabel: songTitle)
               userTriggeredButton()
    }
    
    @IBAction func Play(_ sender: Any) {
        
        let play = NSNotification.Name.Spotify.playSong
        let pause = NSNotification.Name.Spotify.pauseSong
        NotificationCenter.default.post(name: isPlaying ? pause : play, object: nil)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ExpandedTrackViewController {
            destination.isAdmin = isAdmin
        }
    }
}

extension MiniPlayerViewController{
    /*
     20.06.2018 - Chris
     
     Marquee settings
     */
    func marqueeLabelMiniPlayer(MarqueeLabel label: MarqueeLabel){
        label.type = .continuous
        label.speed = .duration(10)
        label.trailingBuffer = 50
        label.fadeLength = 5.0

    }
    
    func setting(song: TrackModel?){
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
        print("func call tapGesturee")
        guard let song = currentSong else{
            return
        }
        delegate?.expandSong(song: song)
    }
    func swipeUpGesture(){
        let swipeUp = UISwipeGestureRecognizer(target: self, action : #selector(swipeGesture))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        self.view.isUserInteractionEnabled = true
    }
    
    @objc
    func swipeGesture(){
        guard let song = currentSong else{
                        return
                    }
                        delegate?.expandSong(song: song)
    }
    
    func getIsPlaying() -> Bool{
        return isPlaying
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
/*
     method to trigger admin or user
     */
    func userTriggeredButton(){
        var snap: String = ""
        
        ref.child("parties/\(partyID)/Host").observeSingleEvent(of: .value, with: { (snapshot) in
            snap = snapshot.value as! String
        })
        playPause.isHidden = false
        isAdmin = false

        //       for broadcasting       ->      playPause.setImage(UIImage(named: "baseline_rss_feed_white_36pt"), for: .normal)
        

        if(uid == snap){
            playPause.isHidden = false
            isAdmin = true
        }
    }
}



extension MiniPlayerViewController: SPTAudioStreamingPlaybackDelegate{
    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
//        songTitle.text = metadata.currentTrack?.name
//        artist.text = metadata.currentTrack?.artistName
//
//
//        thumbImage.kf.setImage(with: URL(string: (metadata.currentTrack?.albumCoverArtURL)!))
//    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        //TODO set ui position of track
        //print("Player Did change Position")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
         //print("Player Did change playback status")
        //TODO toggle play button design
        self.isPlaying = isPlaying
        
            UIView.animate(withDuration: 0.3, animations: {
                self.playPause.alpha = 0.3
            }, completion: {(finished) in
                if(isPlaying){
                    self.playPause.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)
                }else{
                    self.playPause.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
                }
                    UIView.animate(withDuration: 0.5, animations:{
                        self.playPause.alpha = 1.0
                    },completion:nil)
            })
        
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

