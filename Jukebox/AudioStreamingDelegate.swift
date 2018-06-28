//
//  AudioStreamingDelegate.swift
//  test
//
//  Created by Philipp on 28.04.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import FirebaseDatabase
import AVFoundation
import MediaPlayer
import Kingfisher

class AudioStreamingDelegate: NSObject {
    
    
    
    func update() {
        print("Streaming Delegate Will update to Party with id \(currentPartyId)")
        
        manageRemoteHandlers()
        
        
        // Define Now Playing Info
        /*if currentTrack != nil {
         print("Writing to MP Controller")
         var nowPlayingInfo = [String : Any]()
         nowPlayingInfo[MPMediaItemPropertyTitle] = (currentTrack?.songName)!
         nowPlayingInfo[MPMediaItemPropertyArtist] = (currentTrack?.artist)!
         nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = Double((currentTrack?.duration)!) / 1000
         nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (currentTrack?.playbackStatus?.position)!
         
         //nowPlayingInfo[MPMediaItemPropertyArtwork]
         
         if let image = UIImage(named: "defaultPartyImageBlue") {
         nowPlayingInfo[MPMediaItemPropertyArtwork] =
         MPMediaItemArtwork(boundsSize: image.size) { size in
         return image
         }
         }
         nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = (currentTrack?.isPlaying)! ? 1 : 0
         
         // Set the metadata
         MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
         }*/
    }

    @objc func prev() {
        let ref = Database.database().reference().child("/parties/\(currentParty!)/currentlyPlaying/playbackStatus")
        SPTAudioStreamingController.sharedInstance().seek(to: 0) { (error) in
            if let error = error {print(error); return}
            ref.setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
        }
    }
    
    @objc func next() {
        getNextTrack{ self.play() }
    }
    
    @objc func toggle() {
        print("Toggle")
        if currentTrack == nil{
            print("curr is nil")
            getNextTrack{ self.play() }
        } else {
            if (currentTrack?.isPlaying)! { pause() }
            else { play() }
        }
    }
    
    func play() {
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        if let currentMetadata = SPTAudioStreamingController.sharedInstance().metadata{
            var id = currentMetadata.currentTrack?.uri
            id?.removeFirst(14)
            if id == currentTrack?.trackId{
                SPTAudioStreamingController.sharedInstance().setIsPlaying(true) { (error) in
                    if let error = error { print(error); return}
                    ref.child("currentlyPlaying/isPlaying").setValue(true)
                    ref.child("currentlyPlaying/playbackStatus").setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
                    return
                }
            }
        }
        let trackId = currentTrack?.trackId
        SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(trackId!)", startingWith: 0, startingWithPosition: (currentTrack?.playbackStatus?.position)!, callback: { (error) in
            if let error = error { print(error); return }
            ref.child("currentlyPlaying/isPlaying").setValue(true)
            ref.child("currentlyPlaying/playbackStatus").setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
        })
    }

    func pause() {
        print("Pause")
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        
        SPTAudioStreamingController.sharedInstance().setIsPlaying(false) { (error) in
            if let error = error { print(error) }
            print("Paused Spotify")
            isBroadcasting = false
            ref.child("currentlyPlaying/isPlaying").setValue(false)
            ref.child("currentlyPlaying/playbackStatus").setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
        }
    }
    
    func getNextTrack(completion: @escaping ()->Void) {
        let nextTrackId = currentQueue.first?.trackId
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        
        swapToHistory {
            ref.child("/queue/\(nextTrackId!)").observeSingleEvent(of: .value) { (snapshot) in
                let next = snapshot.value as! NSDictionary
                next.setValue(snapshot.key, forKey: "id")
                next.setValue(false, forKey: "isPlaying")
                next.setValue(["position": 0, "time": NSDate.timeIntervalSinceReferenceDate], forKey: "playbackStatus")
                ref.child("currentlyPlaying").setValue(next, withCompletionBlock: { (_, _) in
                    ref.child("/queue/\(nextTrackId!)").removeValue(completionBlock: { (_, _) in completion() })
                })
            }
        }
        
    }
    
    func swapToHistory(completion: @escaping () ->Void) {
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        ref.child("/currentlyPlaying").observeSingleEvent(of: .value) { (snapshot) in
            //TODO add number
            if !snapshot.exists() {completion(); return}
            let id = snapshot.childSnapshot(forPath: "id").value as! String
            let prev = snapshot.value as! NSDictionary
            prev.setValue(nil, forKey: "id")
            prev.setValue(nil, forKey: "isPlaying")
            prev.setValue(nil, forKey: "playbackStatus")
            ref.child("history/\(id)").setValue(prev, withCompletionBlock: { (_, _) in
                completion()
            })
        }
    }
    
    func start() {
        print("Starting Broadcast")
    }
    
    func stop() {
        print("Stopping Broadcast")
    }
}

//MARK - Remote Player Extension
extension AudioStreamingDelegate {
    
    func manageRemoteHandlers(){
        //TODO
        print("Setting Remote Controllers")
        let commandCenter = MPRemoteCommandCenter.shared()
        let playHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.play(); return .success }
        let pauseHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.pause(); return .success }
        let nextHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.next(); return .success }
        let prevHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.prev(); return .success }
        let startHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.start(); return .success }
        let stopHandler: (MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus = {
            (event) -> MPRemoteCommandHandlerStatus in
            self.stop(); return .success }
        
        
        
        if currentAdmin{
            if currentPartyId == "" {
                print("Removing Handlers")
                //commandCenter.playCommand.removeTarget(playHandler)
                //commandCenter.pauseCommand.removeTarget(pauseHandler)
                commandCenter.playCommand.isEnabled = false
                commandCenter.pauseCommand.isEnabled = false
                commandCenter.nextTrackCommand.isEnabled = false
                commandCenter.previousTrackCommand.isEnabled = false
            } else {
                print("Adding Handlers")
                commandCenter.playCommand.addTarget(handler: playHandler)
                commandCenter.pauseCommand.addTarget(handler: pauseHandler)
                commandCenter.nextTrackCommand.addTarget(handler: nextHandler)
                commandCenter.previousTrackCommand.addTarget(handler: prevHandler)
            }
        } else {
            if currentPartyId == "" {
                commandCenter.playCommand.removeTarget(startHandler)
                commandCenter.stopCommand.removeTarget(stopHandler)
            } else {
                commandCenter.playCommand.addTarget(handler: startHandler)
                commandCenter.stopCommand.addTarget(handler: stopHandler)
            }
        }
    }
    
    func updatePlayingCenter(_ audioStreaming: SPTAudioStreamingController!){
        if let track = audioStreaming.metadata.currentTrack{
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = track.name
            nowPlayingInfo[MPMediaItemPropertyArtist] = track.artistName
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = track.albumName
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track.duration
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioStreaming.playbackState.position
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
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.loggedIn, object: nil)
        
        
        print("Did Login")
        
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggle), name: NSNotification.Name.Spotify.toggle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(next), name: NSNotification.Name.Spotify.nextSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(prev), name: NSNotification.Name.Spotify.prevSong, object: nil)
        
        
        //setupRemoteTransportControls()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(play), name: NSNotification.Name.Spotify.playSong, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(pause), name: NSNotification.Name.Spotify.pauseSong, object: nil)
        /*let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //Update your button here for the pause command
            print(event.command)
            print("Pause")
            SPTAudioStreamingController.sharedInstance().setIsPlaying(false, callback: { (e) in
                if e != nil { print(e) }
            })
            return .success
        }
        
        commandCenter.playCommand.addTarget { (event) -> MPRemoteCommandHandlerStatus in
            //Update your button here for the play command
            print("Play")
            SPTAudioStreamingController.sharedInstance().setIsPlaying(true, callback: { (e) in
                if e != nil { print(e) }
            })
            return .success
            return .success
        }*/
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Did receive Error")
        print(error)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("Did receive Message")
    }
    
    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did Logout")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.toggle, object: nil)
    }
    
    func audioStreamingDidEncounterTemporaryConnectionError(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did encounter tmp Connection Error")
    }
    
    func audioStreamingDidDisconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did disconnect")
    }
    
    func audioStreamingDidReconnect(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did Reconnect")
    }
}

extension AudioStreamingDelegate: SPTAudioStreamingPlaybackDelegate{
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        updatePlayingCenter(audioStreaming)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
        updatePlayingCenter(audioStreaming)
    }
    
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didSeekToPosition position: TimeInterval) {
        updatePlayingCenter(audioStreaming)
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStartPlayingTrack trackUri: String!) {
        //print("Player Did start playing track")
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didStopPlayingTrack trackUri: String!) {
        if (currentTrack?.isPlaying)! {
            print("Track stopped, need to get new one")
            self.getNextTrack { self.play() }
        }
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
    
    
    
    
    // Mark - Unsupported Functions
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) { }
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) { }
    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) { }
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) { }
    
    
}
