//
//  MainViewController.swift
//  test
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseAuth
import VolumeBar

class MainViewController: UINavigationController {

    @IBOutlet weak var naviBar: UINavigationBar!
    //Loading View
    var blurredBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SPTAuth.defaultInstance().session == nil || Auth.auth().currentUser == nil{
            DispatchQueue.main.async { self.performSegue(withIdentifier: "showLogin", sender: self) }
        }
        volumeBar()
        setupLoadingOverlay()
    }
}

//Volume Bar Extension
extension MainViewController{
    func volumeBar(){
        let volumeBar = VolumeBar.shared
        var customStyle = VolumeBarStyle.likeInstagram
        customStyle.trackTintColor = .black
        customStyle.progressTintColor = .white
        customStyle.backgroundColor = UIColor(named: "SolidGrey800")!
        volumeBar.style = customStyle
        volumeBar.start()
    }
}

//Loading Overlay Extension
extension MainViewController{
    func setupLoadingOverlay() {
        self.blurredBackgroundView.frame = view.bounds
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: NSNotification.Name.loading, object: nil, queue: nil) { (e) in
            guard let notification: (loading:Bool, message:String, at: UIViewController) = e.object as? (loading: Bool, message: String, at: UIViewController) else {return}
            if notification.loading {
                notification.at.view.addSubview(self.blurredBackgroundView)
                notification.at.present(self.getAlert(for: notification.message), animated: true, completion: nil)
            } else {
                notification.at.dismiss(animated: true, completion: nil)
                self.blurredBackgroundView.removeFromSuperview()
            }
        }
    }
    
    func getAlert(for message: String) -> UIAlertController {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        return alert
    }
}
