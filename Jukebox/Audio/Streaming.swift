//
//  Streaming.swift
//  Jukebox
//
//  Created by Philipp on 02.07.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import FirebaseDatabase

extension AudioStreamingDelegate {
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
            if(currentTrack?.isPlaying)!{currentTrackPosition = 0}
            SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(trackId!)", startingWith: 0, startingWithPosition: currentTrackPosition, callback: { (error) in
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
        let nextTrackId = currentQueue.first?.trackId
        let ref = Database.database().reference().child("/parties/\(currentParty)")
        if(currentQueue.count > 0){
            swapToHistory {
                ref.child("/queue/\(nextTrackId!)").observeSingleEvent(of: .value) { (snapshot) in
                    let next = snapshot.value as! NSDictionary
                    next.setValue(snapshot.key, forKey: "id")
                    next.setValue(currentTrack?.isPlaying, forKey: "isPlaying")
                    currentTrackPosition = 0
                    next.setValue(["position": currentTrackPosition, "time": NSDate.timeIntervalSinceReferenceDate], forKey: "playbackStatus")
                    ref.child("currentlyPlaying").setValue(next, withCompletionBlock: { (_, _) in
                        ref.child("/queue/\(nextTrackId!)").removeValue(completionBlock: { (_, _) in completion() })
                    })
                }
            }
        }else{ self.pause{ self.swapToHistory { ref.child("currentlyPlaying").setValue(nil); NotificationCenter.default.post(name: NSNotification.Name.Player.lastSong, object: nil)}}}
    }
    
    func swapToHistory(completion: @escaping () ->Void) {
        let ref = Database.database().reference().child("/parties/\(currentParty)")
        ref.child("/currentlyPlaying").observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() {completion(); return}
            let id = snapshot.childSnapshot(forPath: "id").value as! String
            let prev = snapshot.value as! NSDictionary
            prev.setValue(nil, forKey: "id")
            prev.setValue(nil, forKey: "isPlaying")
            prev.setValue(nil, forKey: "playbackStatus")
            ref.child("history/\(id)").setValue(prev, withCompletionBlock: { (_, _) in completion() })
        }
    }
}
