//
//  AudioStreamingDelegate.swift
//  test
//
//  Created by Philipp on 28.04.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import FirebaseDatabase

class AudioStreamingDelegate: NSObject,SPTAudioStreamingDelegate {
    func audioStreamingDidLogin(_ audioStreaming: SPTAudioStreamingController!) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.loggedIn, object: nil)
    
        
        print("Did Login")
        
        SPTAudioStreamingController.sharedInstance().playbackDelegate = self
    
        NotificationCenter.default.addObserver(self, selector: #selector(toggle), name: NSNotification.Name.Spotify.toggle, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(next), name: NSNotification.Name.Spotify.nextSong, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(play), name: NSNotification.Name.Spotify.playSong, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(pause), name: NSNotification.Name.Spotify.pauseSong, object: nil)
    }
    
    @objc func next() {
        getNextTrack{ self.play() }
    }
    
    @objc func toggle() {
        if currentTrack == nil{
            getNextTrack{ self.play() }
        } else {
            if (currentTrack?.isPlaying)! { pause() }
            else { play() }
        }
    }
    
    func play() {
        //TODO lookup in currentlyPlaying before
        //TODO write currentlyPlaying to firebase
        //TODO faster play action
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        print()
        if let currentMetadata = SPTAudioStreamingController.sharedInstance().metadata{
            print(currentMetadata.currentTrack?.uri)
            var id = currentMetadata.currentTrack?.uri
            id?.removeFirst(14)
            if id == currentTrack?.trackId{
                SPTAudioStreamingController.sharedInstance().setIsPlaying(true) { (error) in
                    if error != nil { print(error); return}
                    ref.child("currentlyPlaying/isPlaying").setValue(true)
                    ref.child("currentlyPlaying/playbackStatus").setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
                    return
                }
            }
        }
            
            if currentTrack == nil{
                print("First Case Play")
                if currentQueue.count == 0 {return}
                var trackId:String = currentQueue[0].trackId!
                
                //TODO update queue
                SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(trackId)", startingWith: 0, startingWithPosition: 0, callback: { (error) in
                    if error != nil { print(error); return }
                    
                    ref.child("/queue/\(trackId)").observeSingleEvent(of: .value) { (snapshot) in
                        let playing = snapshot.value as! NSDictionary
                        playing.setValue(snapshot.key, forKey: "id")
                        playing.setValue(true, forKey: "isPlaying")
                        playing.setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate], forKey: "playbackStatus")
                        ref.child("currentlyPlaying").setValue(playing)
                    }
                    
                })
            }else {
                print("second case play")
                let trackId = currentTrack?.trackId
                print(trackId)
                SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(trackId!)", startingWith: 0, startingWithPosition: (currentTrack?.playbackStatus?.position)!, callback: { (error) in
                    if error != nil { print(error); return }
                    print("playing")
                    
                    ref.child("currentlyPlaying/isPlaying").setValue(true)
                    print(SPTAudioStreamingController.sharedInstance().playbackState.position)
                    print(NSDate.timeIntervalSinceReferenceDate)
                    ref.child("currentlyPlaying/playbackStatus").setValue(["position": SPTAudioStreamingController.sharedInstance().playbackState.position, "time": NSDate.timeIntervalSinceReferenceDate])
                    
                    
                    /* ref.child("/queue/\(trackId)").observeSingleEvent(of: .value) { (snapshot) in
                     let playing = snapshot.value as! NSDictionary
                     playing.setValue(snapshot.key, forKey: "id")
                     playing.setValue(true, forKey: "isPlaying")
                     playing.setValue((position: SPTAudioStreamingController.sharedInstance().playbackState.position, time: NSDate.timeIntervalSinceReferenceDate), forKey: "playbackStatus")
                     
                     print(playing)
                     print()
                     //print(Date(timeIntervalSince1970: TimeInterval))
                     //NSDate.timeIntervalSince(NSDate.ini)
                     
                     //ref.child("currentlyPlaying").setValue(playing)
                     }*/
                    print(SPTAudioStreamingController.sharedInstance().playbackState.position)
                    print(NSDate.timeIntervalSinceReferenceDate)
                    /*let ref = Database.database().reference().child("/parties/\(currentPartyId!)")
                     ref.child("/queue/\(trackId)").observeSingleEvent(of: .value) { (snapshot) in
                     let playing = snapshot.value as! NSDictionary
                     playing.setValue(snapshot.key, forKey: "id")
                     ref.child("currentlyPlaying").setValue(playing)
                     }*/
                })
                
                
            }
        
        
        
        
        
    }
    
    
    
    
    func pause() {
        print("Pause")
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        
        SPTAudioStreamingController.sharedInstance().setIsPlaying(false) { (error) in
            if error != nil {
                print(error)
            }
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
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didReceiveError error: Error!) {
        print("Did receive Error")
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
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePosition position: TimeInterval) {
    }
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChangePlaybackStatus isPlaying: Bool) {
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
