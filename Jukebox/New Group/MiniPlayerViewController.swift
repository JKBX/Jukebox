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
    
    
    var delegate: PlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting()

        swipeUpGesture()
        marqueeLabelMiniPlayer(MarqueeLabel: artist)
        marqueeLabelMiniPlayer(MarqueeLabel: songTitle)
        userTriggeredButton(isAdmin: currentAdmin)
        
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "HH:mm:ss"
        let dateString = formatter.string(from: now)
   
        print("\(dateString) , TESTESTEST")
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        playPause.adjustsImageWhenHighlighted = false
    
    }
    
    @IBAction func Play(_ sender: Any) {
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
    
    func setting(){
        if let song = currentTrack {
            songTitle.text = song.songName
            artist.text = song.artist
            thumbImage.kf.indicatorType = .activity
            thumbImage.kf.setImage(with: song.coverUrl, placeholder: UIImage(named: "SpotifyLogoWhite"))
            
        }else {
            //TODO Handle no song in playing yet
            songTitle.text = "Weclome!"
            artist.text = "Awaiting a song to be in the playlist! Please add a song!"
            thumbImage.image = UIImage(named: "SpotifyLogoWhite")

        }
    }
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
    
    
    func songDuration(_ currentTrack: TrackModel){
        var playStatus = currentTrack.playbackStatus
        
        
    }
    //        var time1 = position
    //
    //        var durationTime: String{
    //            let formatter = DateFormatter()
    //            formatter.dateFormat = "mm:ss"
    //            let date = Date(timeIntervalSince1970: time1)
    //            return formatter.string(from: date)
    //        }
    ////       --> progress bar
    ////        durationTime.text = durationTime
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
 
}



extension MiniPlayerViewController: SPTAudioStreamingPlaybackDelegate{
//
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
//
//        songTitle.text = metadata.currentTrack?.name
//        artist.text = metadata.currentTrack?.artistName
//        thumbImage.kf.setImage(with: URL(string: (metadata.currentTrack?.albumCoverArtURL)!))
//    }
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
//        var time1 = position
//        
//        var durationTime: String{
//            let formatter = DateFormatter()
//            formatter.dateFormat = "mm:ss"
//            let date = Date(timeIntervalSince1970: time1)
//            return formatter.string(from: date)
//        }
////       --> progress bar
////        durationTime.text = durationTime
//    }
//    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
         //print("Player Did change playback status")
        if (currentAdmin){
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
            })}
    }
//
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
//        //print("Player Did start playing track")
//    }
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
//
//    }
//    
//    
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) {
//         print("Player Did change volume")
//    }
//    
//    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) {
//         print("Player Did skip to next track")
//    }
//    
//    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) {
//         print("Player Did skip to previous track")
//    }
//    
//    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
//         print("Player Did become active playback device")
//    }
//    
//    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
//         print("Player Did become inactive playback device")
//    }
//    
//    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) {
//         print("Player Did lose permission")
//    }
//    
//    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) {
//         print("Player Did pop queue")
//    }
//    
//    
//    // Mark - Unsupported Functions
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
//        //Seeking will not be supported
//    }
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) {
//        //Different Shufle Status will not be supported
//    }
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) {
//        //Different Repeat modes will not be supported
//    }
//    
//    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) {
//        //Not Needed ???
//        //print("Player Did Receive Playback Event")
//    }
//    
}
//
