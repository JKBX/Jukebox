//
//  AudioStreamingDelegate.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Philipp. All rights reserved.
//

import FirebaseDatabase
import AVFoundation
import MediaPlayer
import Kingfisher

class AudioStreamingDelegate: NSObject {

    var partyTMP: String?

    func willUpdate() {
        partyTMP = currentParty
    }
    
    typealias PlaybackStatus = (position: TimeInterval, time: TimeInterval, delay: TimeInterval)
    
     

    func update() {
        if currentParty == ""{
            if currentAdmin && currentTrack != nil { pause(){ self.stopAudioSession()}}
            else { stop(){self.stopAudioSession()} }
            invalidateRemotes()
            freeObservers()
            
            partyTMP = nil
        } else {
            startAudioSession()
            setupRemotes()
            setupObservers()
        }
    }

    @objc func prev() {
        //TODO write correct pos to firebase
        let ref = Database.database().reference().child("/parties/\(currentParty)/currentlyPlaying/playbackStatus")
        SPTAudioStreamingController.sharedInstance().seek(to: 0) { (error) in
            if let error = error {print(error); return}
            ref.setValue(["position": 0, "time": NSDate.timeIntervalSinceReferenceDate])
        }
    }

    @objc func next() {
        SPTAudioStreamingController.sharedInstance().setIsPlaying(false) { (error) in
                        if let error = error { print(error); return }}
        if (currentTrack?.isPlaying)!{
            self.getNextTrack{  self.play() }
        }
        else{
            getNextTrack{ self.pause(){}}
        }
    }

    @objc func toggle() {
        print("Toggle")
        if currentTrack == nil{
            print("curr is nil")
            self.getNextTrack{ self.play() }
        } else {
            if (currentTrack?.isPlaying)! { pause(){} }
            else { self.play() }
        }
    }

    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(toggle), name: NSNotification.Name.Spotify.toggle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(next), name: NSNotification.Name.Spotify.nextSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(prev), name: NSNotification.Name.Spotify.prevSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(broadcast), name: NSNotification.Name.Spotify.broadcast, object: nil)
    }
    
    func freeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.toggle, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.nextSong, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.prevSong, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.broadcast, object: nil)
    }


}



//MARK - Remote Player Extension
extension AudioStreamingDelegate {

    func setupAudioSession(){
        UIApplication.shared.beginReceivingRemoteControlEvents()
        do { try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback) }
        catch let error as NSError { print(error.localizedDescription) }
    }

    func startAudioSession() {
        if SPTAuth.defaultInstance().session.isValid(){
            let accessToken = SPTAuth.defaultInstance().session.accessToken
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: accessToken)
        } else { print("Session not valid")}
    }

    //TODO realy stop it
    func stopAudioSession() {
        SPTAudioStreamingController.sharedInstance().logout()
    }

    func resetAudioSession() {
        UIApplication.shared.endReceivingRemoteControlEvents()
        //AVAudioSession.sharedInstance().setCategory(nil)
        do { try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback) }
        catch let error as NSError { print(error.localizedDescription) }
    }

    func invalidateRemotes() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.nextTrackCommand.removeTarget(nil)
        commandCenter.previousTrackCommand.removeTarget(nil)
    }

    func setupRemotes() {
        let commandCenter = MPRemoteCommandCenter.shared()
        let playHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.play(); return .success }
        let pauseHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.pause(){}; return .success }
        let nextHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.next(); return .success }
        let prevHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.prev(); return .success }
        let startHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.updateBroadcast(); return .success }
        let stopHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.stop(){}; return .success }

        if currentAdmin {
            commandCenter.playCommand.addTarget(handler: playHandler)
            commandCenter.pauseCommand.addTarget(handler: pauseHandler)
            commandCenter.nextTrackCommand.addTarget(handler: nextHandler)
            commandCenter.previousTrackCommand.addTarget(handler: prevHandler)
        } else {
            commandCenter.playCommand.addTarget(handler: startHandler)
            commandCenter.stopCommand.addTarget(handler: stopHandler)
        }
    }

    func updatePlayingCenter(_ audioStreaming: SPTAudioStreamingController!){
        if let track = audioStreaming.metadata.currentTrack{
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
            nowPlayingInfo[MPMediaItemPropertyArtist] = track.artistName
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = track.albumName
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTrackPosition
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = audioStreaming.playbackState.isPlaying ? 1 : 0
            ImageDownloader.default.downloadImage(with: URL(string: track.albumCoverArtURL!)!) { (result, _, _, _) in
                guard let image: UIImage = result else { print("Can't cast result to UIImage."); return}
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { size in return image }
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
}

extension AudioStreamingDelegate: SPTAudioStreamingDelegate{

    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did Login")
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.loggedIn, object: nil)
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        
        setupAudioSession()
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch let error as NSError { print(error.localizedDescription) }
    }
    
    func stop(completion: @escaping ()->Void) {
        SPTAudioStreamingController.sharedInstance().setIsPlaying(false) { (error) in
            if let error = error {print(error); completion();return}
            completion()
        }
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Did receive Error")
        print(error)
        //TODO Did receive Error
        //some(Error Domain=com.spotify.ios-sdk.playback Code=1006 "Context failed"

    }

    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did Logout")
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.loggedOut, object: nil)
        
        do { try AVAudioSession.sharedInstance().setActive(false) }
        catch let error as NSError { print(error.localizedDescription) }
        
    }

    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {}
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {}
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {}
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {}

}

extension AudioStreamingDelegate: SPTAudioStreamingPlaybackDelegate{

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        updatePlayingCenter(audioStreaming)
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        updatePlayingCenter(audioStreaming)
        let ref = Database.database().reference().child("/parties/\(currentParty)/currentlyPlaying")
        if isPlaying && currentAdmin {
            ref.child("isPlaying").setValue(true)
            let position = SPTAudioStreamingController.sharedInstance().playbackState.position
            let time = NSDate.timeIntervalSinceReferenceDate
            
            ref.child("playbackStatus").setValue(["position":position, "time": time, "delay": nil])
        }
    }


    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
        updatePlayingCenter(audioStreaming)
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        //print("Player Did start playing track")
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        if (currentTrack?.isPlaying)! && currentAdmin{
            print("Track stopped, need to get new one")
            /*DispatchQueue.main.async(execute: {() -> Void in*/ self.getNextTrack { self.play() } //})
        }
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        currentTrackPosition = position
        if let currentTrack = currentTrack {
            if currentTrack.isPlaying{
               if let status = currentTrack.playbackStatus as? (position: TimeInterval, time: TimeInterval, delay: TimeInterval?) {
                
                guard let statusDelay = status.delay else {
                    let ref = Database.database().reference().child("/parties/\(currentParty)/currentlyPlaying")
                    let should = status.position + NSDate.timeIntervalSinceReferenceDate - status.time
                    let delay = should-SPTAudioStreamingController.sharedInstance().playbackState.position
                    ref.child("playbackStatus/delay").setValue(delay)
                    return
                }
                
                
                let should = status.position + NSDate.timeIntervalSinceReferenceDate - status.time
                let delay = should-position//SPTAudioStreamingController.sharedInstance().playbackState.position
                let misplacedBy = delay-statusDelay
                if delay > 0.1  {
                    print("Delay is: \(delay)\nShould be: \(statusDelay)")
                    self.updateBroadcast()
                }
                
                //let should = status.position + NSDate.timeIntervalSinceReferenceDate - status.time //- status.delay
                  //  print(should-position+delay)
                //print(status.delay)
                
                //let should = status.position + NSDate.timeIntervalSinceReferenceDate - status.time - position
               } else { print("Status not set ") }
            }
        }
    }

    




    
    // Mark - Unsupported Functions
  
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) { }
    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) { }
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) { }
    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) { }
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) { }
    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {}
    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {}
    
}
