//
//  ExpandedTrackViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class ExpandedTrackViewController: UIViewController, SongSubscriber {

    
    let durationPrimary = 4.0
    let backingPicViewEdgeInset: CGFloat = 15.0
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
    
//    outlet collection
    @IBOutlet weak var backingPicViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backingPicViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backingPicViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var backingPicViewBottomConstraint: NSLayoutConstraint!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .overFullScreen
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backingPicView.image = backingPic
        scrollView.contentInsetAdjustmentBehavior = .never
        // Do any additional setup after loading the view.
        
        scrollView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackingPicViewIN()
    }
    
    

}
extension ExpandedTrackViewController{
    
    private func setBackingPicView(presenting: Bool){
        let edgeInset: CGFloat = presenting ? backingPicViewEdgeInset : 0
        let dimmerAlpha: CGFloat = presenting ? 0.3 : 0
        let cornerRadius: CGFloat = presenting ? cardCornerRadius : 0
        
        backingPicViewLeadingConstraint.constant = edgeInset
        backingPicViewTrailingConstraint.constant = edgeInset
        let aspectRatio = backingPicView.frame.height / backingPicView.frame.width
        backingPicViewTopConstraint.constant = edgeInset * aspectRatio
        backingPicViewBottomConstraint.constant = edgeInset * aspectRatio
        
        dimmerView.alpha = dimmerAlpha
        
        backingPicView.layer.cornerRadius = cornerRadius
        
        
    }
    func animateBackingPicView(presenting: Bool){
        UIView.animate(withDuration: durationPrimary){
            self.setBackingPicView(presenting: presenting)
            self.view.layoutIfNeeded()
        }
    }
    func animateBackingPicViewIN(){
        animateBackingPicView(presenting: true)
    }
    func animateBackingPicViewOUT(){
        animateBackingPicView(presenting: false)
    }
    
    @IBAction func getOutAction(_ sender: Any) {
        self.dismiss(animated: false)
    }
}
