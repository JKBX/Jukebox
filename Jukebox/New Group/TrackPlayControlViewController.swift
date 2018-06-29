//
//  TrackPlayControlViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import MarqueeLabel
import Firebase

class TrackPlayControlViewController: UIViewController {
    
    @IBOutlet weak var songTitle: MarqueeLabel!
    @IBOutlet weak var artist: MarqueeLabel!
    @IBOutlet weak var songDuration: UILabel!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        marqueeLabelTrackPlayer(MarqueeLabel: songTitle)
        marqueeLabelTrackPlayer(MarqueeLabel: artist)
        setFields()
        if((currentTrack?.isPlaying)!){
            playPauseButton.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
        }else{playPauseButton.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)}
        
        Database.database().reference().child("/parties/\(currentParty)/currentlyPlaying").child("/id").observe(.value, with: { (snapshot) in  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change  - 0.5 - to desired number of seconds
            self.setFields()
            }})
        Database.database().reference().child("/parties/\(currentParty)/currentlyPlaying").child("/isPlaying").observe(.value, with: { (snapshot) in
            
            UIView.animate(withDuration: 0.3, animations: {
                self.playPauseButton.alpha = 0.3
            }, completion: {(finished) in
                if("\(snapshot.value!)" == "1"){
                    self.playPauseButton.setImage(UIImage(named: "baseline_pause_circle_outline_white_36pt"), for: .normal)
                }else{
                    self.playPauseButton.setImage(UIImage(named: "baseline_play_circle_outline_white_36pt"), for: .normal)
                }
                UIView.animate(withDuration: 0.2, animations:{
                    self.playPauseButton.alpha = 1.0
                },completion:nil)
            })
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        playPauseButton.isHidden = !currentAdmin
        previousButton.isHidden = !currentAdmin
        nextButton.isHidden = !currentAdmin
        
        
        
    }
    
    @IBAction func playButton(_ sender: Any) {
        
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.toggle, object: nil)
        
    }
    
    @IBAction func previousButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.prevSong, object: nil)
    }
    
    @IBAction func nextButton(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.Spotify.nextSong, object: nil)
    }

}
extension TrackPlayControlViewController{
    func setFields(){
        songTitle.text = currentTrack?.songName
        artist.text = currentTrack?.artist
        print("\(currentTrack?.artist) + ARTIST TEST")
    }

    // Marquee settings
    func marqueeLabelTrackPlayer(MarqueeLabel label: MarqueeLabel){
        label.type = .continuous
        label.speed = .duration(10)
        label.trailingBuffer = 50
        label.fadeLength = 5.0
        label.isUserInteractionEnabled = false
    }
    
    func onCurrentTrackChangedTrackPlayer(_ snapshot: DataSnapshot) {
       
        
    }
 
}




