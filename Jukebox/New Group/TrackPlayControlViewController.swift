//
//  TrackPlayControlViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class TrackPlayControlViewController: UIViewController, TrackSubscriber {
    
    var currentSong: Track?{
        didSet{
        setFields()
        }
    }
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var songDuration: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setFields()
    
    }
    override func viewWillAppear(_ animated: Bool) {
     
    }
    
    @IBAction func playButton(_ sender: Any) {
     
    }
    
    @IBAction func previousButton(_ sender: Any) {
        
    }
    
    @IBAction func nextButton(_ sender: Any) {
        
    }

}
extension TrackPlayControlViewController{
    // important: songTitle is nil before
    func setFields(){
        guard songTitle != nil else{
            return
        }

        songTitle.text = currentSong?.songName
        artist.text = currentSong?.artist
    }
}

extension TrackPlayControlViewController: SPTAudioStreamingPlaybackDelegate{
    

    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        var durationTime: String{
            let formatter = DateFormatter()
            formatter.dateFormat = "mm:ss"
            let date = Date(timeIntervalSince1970: metadata.currentTrack!.duration)
            return formatter.string(from: date)
        }
        print("func call audioStreaming in TrackPlayController")
        songTitle.text = metadata.currentTrack?.name
        artist.text = metadata.currentTrack?.artistName
        songDuration.text = durationTime
    }
    
    }


    


