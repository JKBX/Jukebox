//
//  TrackPlayControlViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Kingfisher

class TrackPlayControlViewController: UIViewController {

    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var songDuration: UILabel!
    

   
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        songTitle.text = metadata.currentTrack?.name
        artist.text = metadata.currentTrack?.artistName
        songDuration.text = durationTime
    }
    
    }
    
    


