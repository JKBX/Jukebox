//
//  AudioStreamingDelegate.swift
//  Jukebox
//
//  Created by Philipp on 28.04.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import FirebaseDatabase
import AVFoundation
import MediaPlayer
import Kingfisher

class AudioStreamingDelegate: NSObject {

    var partyTMP: String?
    var updatingBroadcast = false

    func willUpdate() {
        partyTMP = currentParty
    }
    
    typealias PlaybackStatus = (position: TimeInterval, time: TimeInterval, delay: TimeInterval)
    
     

    func update() {
        if currentParty == ""{
            if currentAdmin{ pause(){ self.stopAudioSession()}}
            else { stop(){self.stopAudioSession()} }
            invalidateRemotes()
            partyTMP = nil
        } else {
            startAudioSession()
            setupRemotes()
        }
    }

    @objc func prev() {
        //TODO write correct pos to firebase
        let ref = Database.database().reference().child("/parties/\(currentParty)/currentlyPlaying/playbackStatus")
        SPTAudioStreamingController.sharedInstance().seek(to: 0) { (error) in
            if let error = error {print(error); return}
            ref.setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
        }
    }

    @objc func next() {
        currentTrackPosition = 0.0
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

    func play() {
        if(currentAdmin){
            let ref = Database.database().reference().child("/parties/\(currentParty)")
            if let currentMetadata = SPTAudioStreamingController.sharedInstance().metadata{
                var id = currentMetadata.currentTrack?.uri
                id?.removeFirst(14)
                if id == currentTrack?.trackId{
                    SPTAudioStreamingController.sharedInstance().setIsPlaying(true) { (error) in
                        if let error = error { print(error); return}
                    }
                    return
                }
            }
            let trackId = currentTrack?.trackId
            SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(trackId!)", startingWith: 0, startingWithPosition: (currentTrack?.playbackStatus?.position)!, callback: { (error) in
                if let error = error { print(error); return }
            })
            
        }
        
    }

    func pause(completion: @escaping ()->Void) {
        let partyId:String = (currentParty != "") ? (currentParty) : (partyTMP!)
        let ref = Database.database().reference().child("/parties/\(partyId)")
        print(partyId)
        
        SPTAudioStreamingController.sharedInstance().setIsPlaying(false) { (error) in
            if let error = error { print(error); return }
            print("Paused Spotify")
            ref.child("currentlyPlaying/isPlaying").setValue(false)
            if(currentTrack == nil){
                ref.child("currentlyPlaying/playbackStatus").setValue(["position": currentTrackPosition, "time": NSDate.timeIntervalSinceReferenceDate])
                return}
            if(currentTrack?.isPlaying)!{
                ref.child("currentlyPlaying/playbackStatus").setValue(["position": currentTrackPosition, "time": NSDate.timeIntervalSinceReferenceDate])}
            else{
                ref.child("currentlyPlaying/playbackStatus").setValue(["position": 0, "time": NSDate.timeIntervalSinceReferenceDate])
            }
            completion()
        }
    }

    func getNextTrack(completion: @escaping ()->Void) {
//        Fix fix the get rid of the bug --> when you skip the last song in expandedTrackPlayer
        if(currentQueue.count > 0){
        let nextTrackId = currentQueue.first?.trackId
        let ref = Database.database().reference().child("/parties/\(currentParty)")

        swapToHistory {
            ref.child("/queue/\(nextTrackId!)").observeSingleEvent(of: .value) { (snapshot) in
                let next = snapshot.value as! NSDictionary
                next.setValue(snapshot.key, forKey: "id")
                next.setValue(currentTrack?.isPlaying, forKey: "isPlaying")
                next.setValue(["position": 0, "time": NSDate.timeIntervalSinceReferenceDate], forKey: "playbackStatus")
                ref.child("currentlyPlaying").setValue(next, withCompletionBlock: { (_, _) in
                    ref.child("/queue/\(nextTrackId!)").removeValue(completionBlock: { (_, _) in completion() })
                })
            }
        }
        }else{return}
    }

    func swapToHistory(completion: @escaping () ->Void) {
        let ref = Database.database().reference().child("/parties/\(currentParty)")
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
        print("Did Login")
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.loggedIn, object: nil)
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(toggle), name: NSNotification.Name.Spotify.toggle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(next), name: NSNotification.Name.Spotify.nextSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(prev), name: NSNotification.Name.Spotify.prevSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(broadcast), name: NSNotification.Name.Spotify.broadcast, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(stop), name: NSNotification.Name.Spotify.stopBroadcast, object: nil)
    
//        OBSERVER FÜR Broadcast
        
        setupAudioSession()
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch let error as NSError { print(error.localizedDescription) }
    }
    @objc func broadcast(){
        if isBroadcasting {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Player.trackChanged, object: nil)
            DispatchQueue.main.async(execute: {() -> Void in
            self.stop {
                print("Stopped \(Thread.current)")
                isBroadcasting = false
                NotificationCenter.default.post(name: NSNotification.Name.Player.broadcast, object: nil)
            }
            })
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(updateBroadcast), name: NSNotification.Name.Player.trackChanged, object: nil)
            updateBroadcast()
        }
    }
    //TODO 3 states for broadcast: inactive active updating
    //TODO update status from host
    //TODO deactivate broadcast when failing
    @objc func updateBroadcast(){
        if self.updatingBroadcast{print("Already Updating"); return}
        self.updatingBroadcast = true
        if let currentTrack = currentTrack{
            if let status = currentTrack.playbackStatus as? PlaybackStatus{
                if currentTrack.isPlaying{
                    DispatchQueue.main.async(execute: {() -> Void in
                        self.stop {
                            self.start(currentTrack, status: status, completion: { (success, trial) in
                                print("\(success ? "": "Not ")Playing after \(trial) trials")
                                self.updatingBroadcast = false
                                isBroadcasting = success
                                NotificationCenter.default.post(name: NSNotification.Name.Player.broadcast, object: nil)
                            })
                        }
                    })
                } else {print("Not Playing or delay not set"); stop{self.updatingBroadcast = false}}
            } else {print("No Playback status"); stop{self.updatingBroadcast = false}}
        } else {print("No Current Track"); stop{self.updatingBroadcast = false}}
    }
    
    func start(_ currentTrack: TrackModel, status: PlaybackStatus, trial: Int? = 0,completion: @escaping (_: Bool, _: Int)->Void) {
        let maxRepetitions = 10
        let trial = trial ?? 0
        if trial > maxRepetitions {self.stop { completion(false, trial) }; return}
        
        
        let id = currentTrack.trackId
        let delay = NSDate.timeIntervalSinceReferenceDate - status.time - status.delay
        let position = status.position + delay
        let extendedPosition = position + 1
        
        let track = "spotify:track:\(id!)"
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(track, startingWith: 0, startingWithPosition: extendedPosition, callback: { (error) in
            if let error = error { print(error); self.stop{completion(false, trial)}; return }
            
            guard let metadata = SPTAudioStreamingController.sharedInstance().metadata else {
                self.stop { self.start(currentTrack, status: status, trial: trial+1, completion: { (success, trial) in completion(success, trial) })}; return
            }
            if let currentPlayback = metadata.currentTrack {
                if currentPlayback.uri != track && trial == 0 {
                    sleep(1); self.stop { self.start(currentTrack, status: status, trial: trial+1, completion: { (success, trial) in completion(success, trial) })}; return
                }
            } else {
                if trial == 0{
                    sleep(1); self.stop { self.start(currentTrack, status: status, trial: trial+1, completion: { (success, trial) in completion(success, trial) })}; return }
            }
            
            repeat {
                usleep(1000)
            } while (self.getDelay(from: status) < 0)
            print(self.getDelay(from: status))
            
            if abs(self.getDelay(from: status)) > 0.01 {
                self.stop { self.start(currentTrack, status: status, trial: trial+1, completion: { (success, trial) in completion(success, trial) })}; return
            }
            completion(true, trial)
            return
        })
        
    }
    
    func getDelay(from status: (position: TimeInterval, time: TimeInterval, delay: TimeInterval)) -> TimeInterval {
        return status.position + NSDate.timeIntervalSinceReferenceDate - status.time + status.delay-SPTAudioStreamingController.sharedInstance().playbackState.position
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
    }

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveMessage message: String!) {
        print("Did receive Message")
    }

    func audioStreamingDidLogout(_ audioStreaming: SPTAudioStreamingController!) {
        do { try AVAudioSession.sharedInstance().setActive(false) }
        catch let error as NSError { print(error.localizedDescription) }
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.toggle, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.nextSong, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.prevSong, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.broadcast, object: nil)
        
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
        NotificationCenter.default.post(name: NSNotification.Name.Player.position, object: nil)
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
                if delay > 0.1 {
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
    



    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did become active")
    }

    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did become inactive")
    }

    //TODO Did receive Error
    //some(Error Domain=com.spotify.ios-sdk.playback Code=1006 "Context failed"

    // Mark - Unsupported Functions
  
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeVolume volume: SPTVolume) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeShuffleStatus enabled: Bool) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangeRepeatStatus repeateMode: SPTRepeatMode) { }
    func audioStreamingDidLosePermission(forPlayback audioStreaming: SPTAudioStreamingController!) { }
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceive event: SpPlaybackEvent) { }
    func audioStreamingDidSkip(toNextTrack audioStreaming: SPTAudioStreamingController!) { }
    func audioStreamingDidSkip(toPreviousTrack audioStreaming: SPTAudioStreamingController!) { }
    func audioStreamingDidPopQueue(_ audioStreaming: SPTAudioStreamingController!) { }


}
