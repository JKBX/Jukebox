//
//  ExpandedTrackViewController.swift
//  Jukebox
//
//  Created by Christian Reiner on 14.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

// Chris - 17.06.2018
protocol ExpandedTrackSourceProtocol: class {
    var frameInWindow: CGRect { get }
    var coverImageView: UIImageView { get }
}


class ExpandedTrackViewController: UIViewController, SongSubscriber {

    
    let durationPrimary = 4.0
//    gibt an wie weit das fenster gecropped wird
    let backingPicViewEdgeInset: CGFloat = 10.0
    
    //    MARK: TODO: top corner fixen ?! ggf Stefan fragen
    let cardCornerRadius: CGFloat = 10
    var currentSong: Track?
    weak var sourceView: ExpandedTrackSourceProtocol!
    
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
    
//    Cover Image constraints
    @IBOutlet weak var coverImageLeading: NSLayoutConstraint!
    @IBOutlet weak var coverImageHeight: NSLayoutConstraint!
    @IBOutlet weak var coverImageBottom: NSLayoutConstraint!
    @IBOutlet weak var coverImageTop: NSLayoutConstraint!
    
    @IBOutlet weak var coverContainerTop: NSLayoutConstraint!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .overFullScreen
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backingPicView.image = backingPic
        scrollView.contentInsetAdjustmentBehavior = .never
        
        coverContainer.layer.cornerRadius = cardCornerRadius
        coverContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setImageLayerStartPoint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackingPicViewIN()
        animateImageLayerIN()
    }
    
    

}

extension ExpandedTrackViewController{
/*
     17.06.2018 - Chris
     Methods for the transition
     
     */
    private var startColor: UIColor{
        return UIColor.white.withAlphaComponent(0.3)
    }
    private var endColor: UIColor {
        return .white
    }
    
    private var imageLayerForOutPosition: CGFloat {
        let imageFrame = view.convert(sourceView.frameInWindow, to: view)
        let input = imageFrame.minY - backingPicViewEdgeInset
        return input
    }
    
    func setImageLayerStartPoint(){
        coverContainer.backgroundColor = startColor
        let startInput = imageLayerForOutPosition
        chevron.alpha = 0
        coverContainer.layer.cornerRadius = 0
        coverContainerTop.constant = startInput
        view.layoutIfNeeded()
    }
    
    func animateImageLayerIN(){
        
        UIView.animate(withDuration: durationPrimary / 4){
            self.coverContainer.backgroundColor = self.endColor
        }
        
        UIView.animate(withDuration: durationPrimary, delay: 0, options: [.curveEaseIn], animations: {
            self.coverContainerTop.constant = 0
            self.chevron.alpha = 1
            self.coverContainer.layer.cornerRadius = self.cardCornerRadius
            self.view.layoutIfNeeded()
        })
    }
    
    func animateImageLayerOUT(completion: @escaping((Bool) -> Void)){
        let endInset = imageLayerForOutPosition
        
        UIView.animate(withDuration: durationPrimary / 4.0,
                       delay: durationPrimary,
                       options: [.curveEaseOut],
                       animations: {
                        self.coverContainer.backgroundColor = self.startColor
        }, completion:{finished in
            completion(finished)
        })
        UIView.animate(withDuration: durationPrimary,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                self.coverContainerTop.constant = endInset
                self.chevron.alpha = 0
                self.coverContainer.layer.cornerRadius = 5
                self.view.layoutIfNeeded()
        })
    }
    
    
    /*
     Chris - 17.06.2018
     func to set the backing layer for the mini player
     */
    
    func setBackingPicView(presenting: Bool){
        let edgeInset: CGFloat = presenting ? backingPicViewEdgeInset : 0
        let dimmerAlpha: CGFloat = presenting ? 0.5 : 0
        let cornerRadius: CGFloat = presenting ? cardCornerRadius : 0
        
        backingPicViewLeadingConstraint.constant = backingPicViewEdgeInset
        backingPicViewTrailingConstraint.constant = -(backingPicViewEdgeInset)
        let aspectRatio = backingPicView.frame.height / backingPicView.frame.width
        backingPicViewTopConstraint.constant = (edgeInset * aspectRatio)
        backingPicViewBottomConstraint.constant = -(edgeInset * aspectRatio)
        
        dimmerView.alpha = dimmerAlpha
//        self.backingPicView.contentMode = .scaleToFill
        self.backingPicView.layer.masksToBounds = true
        self.backingPicView.layer.cornerRadius =  cornerRadius
        

    }
    func animateBackingPicView(presenting: Bool){
        UIView.animate(withDuration: durationPrimary){

            self.setBackingPicView(presenting: presenting)
            self.view.layoutIfNeeded()
            
           

//            for the animation
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
