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


class ExpandedTrackViewController: UIViewController, TrackSubscriber {

    
    let durationPrimary = 0.4
//    gibt an wie weit das fenster gecropped wird
    let backingPicViewEdgeInset: CGFloat = 15
    
    //    MARK: TODO: top corner fixen ?! ggf Stefan fragen
    let cardCornerRadius: CGFloat = 10
    var currentSong: TrackModel?
    var isAdmin: Bool!
    var isPlaying: Bool!
    weak var sourceView: ExpandedTrackSourceProtocol!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var animationLayer: UIView!
    
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
    @IBOutlet weak var lowerModulTopConstraint: NSLayoutConstraint!
    
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
        swipeDownGesture()
        scrollView.isScrollEnabled = false
        scrollView.contentInsetAdjustmentBehavior = .never
        backingPicView.image = backingPic
        coverContainer.layer.cornerRadius = cardCornerRadius
        coverContainer.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setImageLayerStartPoint()
        coverImage.image = sourceView.coverImageView.image
        setCoverImageStartPoint()
        animationLayer.backgroundColor = backingPicView.backgroundColor.unsafelyUnwrapped
        setModulStartPosition()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateBackingPicViewIN()
        animateImageLayerIN()
        animateCoverImageIN()
        animateLowerModulIN()


    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? TrackSubscriber {
            destination.currentSong = currentSong
        }
        if let destination = segue.destination as? TrackPlayControlViewController {
            destination.isAdmin = isAdmin
        }
    }
}

extension ExpandedTrackViewController{
    
    
    
    @IBAction func getOutAction(_ sender: Any) {
        animateBackingPicViewOUT()
        animateCoverImageOUT()
        animateLowerModulOUT()
        animateImageLayerOUT(completion: {_ in
            self.dismiss(animated: false)
        })
        
    }
    /*
     func wipe down function for expanded view
     
     */
    func swipeDownGesture(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action : #selector(swipeGesture))
        swipeDown.direction = .down
        self.scrollView.addGestureRecognizer(swipeDown)
        self.scrollView.isUserInteractionEnabled = true
        print("func call swipeDownGesture first call")
    }

    @objc
    func swipeGesture(){

        print("func call swipeDownGesture")

        animateBackingPicViewOUT()
        animateCoverImageOUT()
        animateLowerModulOUT()
        animateImageLayerOUT(completion: {_ in
            self.dismiss(animated: false)
        })
    }
    
/*
     17.06.2018 - Chris
     Methods for the transition
     
     */
    private var startColor: UIColor{
        return UIColor.gray.withAlphaComponent(0.1)
    }
    private var endColor: UIColor {
        return backingPicView.backgroundColor.unsafelyUnwrapped
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
//    animation to its final point
    
    func animateImageLayerIN(){
        
        UIView.animate(withDuration: durationPrimary / 4){
            self.coverContainer.backgroundColor = self.backingPicView.backgroundColor.unsafelyUnwrapped
            
        }
        
        UIView.animate(withDuration: durationPrimary, delay: 0, options: [.curveEaseIn], animations: {
            self.coverContainerTop.constant = 40
            self.chevron.alpha = 1
            self.coverContainer.layer.cornerRadius = self.cardCornerRadius
            self.view.layoutIfNeeded()
        })
    }
// animation to its origin point
    
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
        
        backingPicViewLeadingConstraint.constant = edgeInset
        backingPicViewTrailingConstraint.constant = -(edgeInset)
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
    

}
/*
 17.06.2018 - Chris
 
 animate the cover image IN and OUT
 */
extension ExpandedTrackViewController{

    func setCoverImageStartPoint(){
        let imageFrame = sourceView.coverImageView.frame
        coverImageHeight.constant = imageFrame.height
        coverImageLeading.constant = imageFrame.minX
        coverImageTop.constant = imageFrame.minY
        coverImageBottom.constant = imageFrame.minY
    }
    
        func animateCoverImageIN(){
        let coverImageEdgeContraint: CGFloat = 30
        let endHeight = coverContainer.bounds.width - coverImageEdgeContraint * 2
        UIView.animate(withDuration: durationPrimary,
                       delay: 0,
                       options: [.curveEaseIn],
                       animations: {
                        self.coverImageHeight.constant = endHeight
                        self.coverImageLeading.constant = coverImageEdgeContraint
                        self.coverImageTop.constant = coverImageEdgeContraint
                        self.coverImageBottom.constant = coverImageEdgeContraint
                        self.view.layoutIfNeeded()
        })
    }
    
    func animateCoverImageOUT(){
        UIView.animate(withDuration: durationPrimary,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations:{
                        self.setCoverImageStartPoint()
                        self.view.layoutIfNeeded()
        })
    }
 
    
}

extension ExpandedTrackViewController{
    private var lowerModulPosition: CGFloat{
        let bounds = view.bounds
        let inset = bounds.height - bounds.width
        return inset
    }
    
    
    func setModulStartPosition(){
        lowerModulTopConstraint.constant = lowerModulPosition
    }
    
    func animateLowerModul(isPresenting: Bool){
        let topInset = isPresenting ? 0 : lowerModulPosition
        UIView.animate(withDuration: durationPrimary,
                       delay: 0.1,
                       options: [.curveEaseIn],
                       animations: {
                self.lowerModulTopConstraint.constant = topInset
                self.view.layoutIfNeeded()
                        print("func call animateLowerModul")

        })
    }
    
    func animateLowerModulIN(){
        animateLowerModul(isPresenting: true)
    }
    
    func animateLowerModulOUT(){
        animateLowerModul(isPresenting: false)
    }
    
}

extension ExpandedTrackViewController: SPTAudioStreamingPlaybackDelegate{
    
    func audioStreaming(_ audioStreaming: SPTAudioStreamingController!, didChange metadata: SPTPlaybackMetadata!) {
        coverImage.kf.setImage(with: URL(string: (metadata.currentTrack?.albumCoverArtURL)!))
    }
}








