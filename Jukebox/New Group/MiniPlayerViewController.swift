//
//  MiniPlayerViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 12.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Kingfisher

protocol MiniPlayerDelegate: class {
    func expandSong(song: Track)
}


class MiniPlayerViewController: UIViewController, SongSubscriber{

    // MARK: Properties
    
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playButton: UIButton!
    var isPlaying: Bool = false
    
    
    //    MARK: Auslagern Methoden Spotify
    
    @IBAction func Play(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.playSong, object: nil)

        SPTAudioStreamingController.sharedInstance().playSpotifyURI("spotify:track:\(currentSong!.trackId!)", startingWith: 0, startingWithPosition: 0, callback: { (error) in
            if error != nil{
                print("Playing")
                
                /*print(SPTAudioStreamingController.sharedInstance().metadata.currentTrack?.name)*/
            }else {print(error)}
        })
    }
    
    
    var currentSong: Track?
    weak var delegate: MiniPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setting(song: nil)
        // Do any additional setup after loading the view.
    }
}

extension MiniPlayerViewController{
    
    
    
    
    func setting(song: Track?){
        if let song = song {
            songTitle.text = song.songName
            artist.text = song.artist
            thumbImage.kf.setImage(with: song.coverUrl)
        }else {
            songTitle.text = nil
            thumbImage.image = nil
        }
        currentSong = song
    }

}

extension MiniPlayerViewController{
    @IBAction func tapGesturee(_ sender: Any) {
        guard let song = currentSong else{
            return
        }
        delegate?.expandSong(song: song)
    }
}
