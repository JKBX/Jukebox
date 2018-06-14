//
//  ExpandedTrackViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class ExpandedTrackViewController: UIViewController, SongSubscriber {

    
    
    let cardCornerRadius: CGFloat = 10
    var currentSong: Track?
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stretchArea: UIView!
    
//    vars for image
    @IBOutlet weak var coverContainer: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var chevron: UIButton!
    
    
    //    backing Image
    
    var backingPic: UIImage?
    @IBOutlet weak var backingPicView: UIImageView!
    @IBOutlet weak var dimmerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .overFullScreen
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentInsetAdjustmentBehavior = .never
        // Do any additional setup after loading the view.
        
        scrollView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    

}
extension ExpandedTrackViewController{
    @IBAction func getOutAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
