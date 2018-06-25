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
    
        
        NotificationCenter.default.addObserver(self, selector: #selector(play), name: NSNotification.Name.Spotify.playSong, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pause), name: NSNotification.Name.Spotify.pauseSong, object: nil)
    }
    
    @objc func play() {
        //TODO lookup in currentlyPlaying before
        //TODO write currentlyPlaying to firebase
        let ref = Database.database().reference().child("/parties/\(currentParty!)")
        
        
        if currentTrack == nil{
            var trackId:String = currentQueue[0].trackId!
            
            //SPTAudioStreamingController.sharedInstance().queueSpotifyURI(<#T##spotifyUri: String!##String!#>, callback: <#T##SPTErrorableOperationCallback!##SPTErrorableOperationCallback!##(Error?) -> Void#>)
            
            //TODO update queue
            SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(trackId)", startingWith: 0, startingWithPosition: 0, callback: { (error) in
                if error != nil { print(error); return }
                
                ref.child("/queue/\(trackId)").observeSingleEvent(of: .value) { (snapshot) in
                    let playing = snapshot.value as! NSDictionary
                    playing.setValue(snapshot.key, forKey: "id")
                    playing.setValue(true, forKey: "isPlaying")
                    playing.setValue((position: SPTAudioStreamingController.sharedInstance().playbackState.position, time: NSDate.timeIntervalSinceReferenceDate), forKey: "playbackStatus")
                    
                    print(playing)
                    print()
                    //print(Date(timeIntervalSince1970: TimeInterval))
                    //NSDate.timeIntervalSince(NSDate.ini)
                    
                    ref.child("currentlyPlaying").setValue(playing)
                }
                
            })
        }else {
            let trackId = currentTrack?.trackId
            print(trackId)
            SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(trackId!)", startingWith: 0, startingWithPosition: 100, callback: { (error) in
                if error != nil { print(error); return }
                print("playing")
                
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
    
    
    
    
    @objc func pause() {
        print("Pause")
        SPTAudioStreamingController.sharedInstance().setIsPlaying(false) { (error) in
            if error != nil {
                print(error)
            }
            print("Paused Spotify")
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
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.playSong, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Spotify.pauseSong, object: nil)
        
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
