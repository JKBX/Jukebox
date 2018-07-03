//
//  Broadcasting.swift
//  Jukebox
//
//  Created by Philipp on 02.07.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

//Broadcasting Extension
extension AudioStreamingDelegate {
    @objc func broadcast(){
        if broadcasting == .active {
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.Player.trackChanged, object: nil)
            //DispatchQueue.main.async(execute: {() -> Void in
            DispatchQueue.main.async { self.stop { broadcasting = .inactive } }
            //})
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(updateBroadcast), name: NSNotification.Name.Player.trackChanged, object: nil)
            updateBroadcast()
        }
    }
    //TODO update status from host
    //TODO deactivate broadcast when failing
    @objc func updateBroadcast(){
        if broadcasting == .updating{print("Already Updating"); return}
        broadcasting = .updating
        if let currentTrack = currentTrack{
            if let status = currentTrack.playbackStatus as? PlaybackStatus{
                if currentTrack.isPlaying{
                    DispatchQueue.main.async {
                        self.stop {
                            self.start(currentTrack, status, 0, { (success) in
                                broadcasting = success ? .active : .inactive
                            })
                        }
                    }
                } else {print("Not Playing or delay not set"); stop{broadcasting = .active}}
            } else {print("No Playback status"); stop{broadcasting = .active}}
        } else {print("No Current Track"); stop{broadcasting = .active}}
    }
    
    func start(_ currentTrack: TrackModel, _ status: PlaybackStatus, _ trial: Int, _ completion: @escaping (_: Bool)->Void) {
        let maxRepetitions = 10
        if trial > maxRepetitions {self.stop { completion(false) }; return}
        
        let track = "spotify:track:\(currentTrack.trackId!)"
        let delay = NSDate.timeIntervalSinceReferenceDate - status.time - status.delay
        let position = status.position + delay + 1 //Start one second ahead and wait for player to match up
        
        SPTAudioStreamingController.sharedInstance().playSpotifyURI(track, startingWith: 0, startingWithPosition: position, callback: { (error) in
            if let error = error { print(error); self.stop{completion(false)}; return }
            
            //Check for missing metadata
            guard let metadata = SPTAudioStreamingController.sharedInstance().metadata else {
                self.stop { self.start(currentTrack, status, trial+1, { (success) in completion(success) })}; return
            }
            //Check for wrong/no track loaded in player
            if let currentPlayback = metadata.currentTrack {
                if currentPlayback.uri != track && trial == 0 {
                    sleep(1); self.stop { self.start(currentTrack, status, trial+1, { (success) in completion(success) })}; return
                }
            } else { if trial == 0{
                sleep(1); self.stop { self.start(currentTrack, status, trial+1, { (success) in completion(success) })}; return
            }}
            
            // Delay return(thus start of playback) until own player is matched up with host
            repeat { usleep(1000) } while (self.getDelay(from: status) < 0)
            
            //Double check if correct starting point has been hit
            if abs(self.getDelay(from: status)) > 0.01 {
                self.stop { self.start(currentTrack, status, trial+1, { (success) in completion(success) })}; return
            }
            completion(true)
            return
        })
        
    }
    
    func getDelay(from status: (position: TimeInterval, time: TimeInterval, delay: TimeInterval)) -> TimeInterval {
        return status.position + NSDate.timeIntervalSinceReferenceDate - status.time + status.delay-SPTAudioStreamingController.sharedInstance().playbackState.position
    }
}
