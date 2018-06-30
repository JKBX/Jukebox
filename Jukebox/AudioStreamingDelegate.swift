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

    //TODO
    //TODO move to streaming delegate
    //SPTAudioStreamingController.sharedInstance().login(withAccessToken: session.accessToken)

    var partyTMP: String?

    func willUpdate() {
        partyTMP = currentParty
    }


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
        let ref = Database.database().reference().child("/parties/\(currentParty)/currentlyPlaying/playbackStatus")
        SPTAudioStreamingController.sharedInstance().seek(to: 0) { (error) in
            if let error = error {print(error); return}
            ref.setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
        }
    }

    @objc func next() {
        if (currentTrack?.isPlaying)!{
            getNextTrack{ self.play() }
        }
        else{
            getNextTrack{ self.pause(){}}
        }
    }

    @objc func toggle() {
        print("Toggle")
        if currentTrack == nil{
            print("curr is nil")
            getNextTrack{ self.play() }
        } else {
            if (currentTrack?.isPlaying)! { pause(){} }
            else { play() }
        }
    }

    func play() {
        let ref = Database.database().reference().child("/parties/\(currentParty)")
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
            ref.child("currentlyPlaying/playbackStatus").setValue(["position":SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
        })
    }

    func pause(completion: @escaping ()->Void) {
        let partyId:String = (currentParty != "") ? (currentParty) : (partyTMP!)
        let ref = Database.database().reference().child("/parties/\(partyId)")
        print(partyId)
        SPTAudioStreamingController.sharedInstance().setIsPlaying(false) { (error) in
            if let error = error { print(error); return }
            print("Paused Spotify")
            print("\(currentTrack?.isPlaying),  TESTESTESTEST")
            ref.child("currentlyPlaying/isPlaying").setValue(false)
            if(currentTrack == nil){return}
            if(currentTrack?.isPlaying)!{
                
                ref.child("currentlyPlaying/playbackStatus").setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])}
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

    func start() {
        print("Starting Broadcast")

        isBroadcasting = true
    }

    func stop(completion: ()->Void) {
        print("Stopping Broadcast")

        isBroadcasting = false
        completion()
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
            self.start(); return .success }
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

        setupAudioSession()
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch let error as NSError { print(error.localizedDescription) }
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

        do { try AVAudioSession.sharedInstance().setActive(false) }
        catch let error as NSError { print(error.localizedDescription) }
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

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
        currentTrackPosition = position
        NotificationCenter.default.post(name: NSNotification.Name.Player.position, object: nil)
        
        //        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { (timer) in
        //            let partyId:String = (currentParty != "") ? (currentParty) : (self.partyTMP!)
        //            let ref = Database.database().reference().child("/parties/\(partyId)")
        //            ref.child("/currentlyPlaying").child("isPosition").setValue(currentTrackPosition)
        //
        //        })
        
    }



    func audioStreamingDidBecomeActivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
        print("Did become active")
    }

    func audioStreamingDidBecomeInactivePlaybackDevice(_ audioStreaming: SPTAudioStreamingController!) {
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


}
