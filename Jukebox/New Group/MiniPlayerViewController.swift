//
//  MiniPlayerViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 12.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

protocol MiniPlayerDelegate: class {
    func expandSong(song: Track)
}


class MiniPlayerViewController: UIViewController, SongSubscriber{

    // MARK: Properties
    
    
    @IBOutlet weak var thumbImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var playButton: UIButton!
   
    
    var currentSong: Track?
    weak var delegate: MiniPlayerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

}





extension MiniPlayerViewController{
    
    func setting(song: Track?){
        if let song = song {
            songTitle.text = song.songName
            loadURLImage(song: song) {
                [weak self] file in self?.thumbImage.image = file
            }
        }else {
            songTitle.text = nil
            thumbImage.image = nil
        }
        currentSong = song
    }
        //    MARK: Helper for loading album picture
    
    
    /*
     load image asynchronously from url
     
     */
    func loadURLImage(song: Track, completion: @escaping((UIImage?) -> (Void))) {
        guard let coverUrl = song.coverUrl,
            let file = Bundle.main.path(forResource: coverUrl.absoluteString, ofType:"jpg") else {return}
    
        DispatchQueue.global(qos: .background).async {
            let pic = UIImage(contentsOfFile: file)
            DispatchQueue.main.async {
                completion(pic)
            }
    }
    }
}

extension MiniPlayerViewController{
    @IBAction func tapGesturee(_ sender: Any) {
        
    }
}
