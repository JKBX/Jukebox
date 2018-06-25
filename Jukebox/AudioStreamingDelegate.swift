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
    
        NotificationCenter.default.addObserver(self, selector: #selector(toggle), name: NSNotification.Name.Spotify.toggle, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(play), name: NSNotification.Name.Spotify.playSong, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(pause), name: NSNotification.Name.Spotify.pauseSong, object: nil)
    }
    
    @objc func toggle() {
        if (currentTrack?.isPlaying)! {
            pause()
        } else {
            play()
        }
    }
    
    func play() {
        //TODO lookup in currentlyPlaying before
        //TODO write currentlyPlaying to firebase
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        
        
        
        if currentTrack == nil{
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
