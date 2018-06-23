//
//  AuthViewController.swift
//  Jukebox
//
//  Created by Philipp on 20.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController {

    @IBOutlet weak var LoginView: UIView!
    @IBOutlet weak var ProfileView: UIView!
    @IBOutlet weak var done: UIBarButtonItem!
    
    //Loading View
    var blurredBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileView.isHidden = true
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        
        Auth.auth().addIDTokenDidChangeListener { (auth, _) in
            print(auth.currentUser)
            if auth.currentUser != nil {
                self.done.isEnabled = auth.currentUser?.displayName != nil
                self.switchView(to: "profileView")
            } else {
                print(auth.currentUser?.displayName == nil)
                self.done.isEnabled = false
                self.switchView(to: "loginView")
            }
            
        }
        //NotificationCenter.default.addObserver(self, selector: #selector(successfulLogin), name: NSNotification.Name.Spotify.loggedIn, object: nil)
        
        
        self.blurredBackgroundView.frame = view.bounds
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.Auth.loading, object: nil, queue: nil) { (e) in
            let notification = e.object as! (loading:Bool, message:String)
            
            if notification.loading {
                self.view.addSubview(self.blurredBackgroundView)
                self.present(self.getAlert(for: notification.message), animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
                self.blurredBackgroundView.removeFromSuperview()
            }  
        }

        // Do any additional setup after loading the view.
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
    
    func switchView(to: String) {
        //TODO switch title
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        if to == "profileView"{
            UIView.transition(with: LoginView, duration: 0.8, options: transitionOptions, animations: {
                self.LoginView.isHidden = true
            })
            UIView.transition(with: ProfileView, duration: 0.8, options: transitionOptions, animations: {
                self.ProfileView.isHidden = false
            })
        } else {
            UIView.transition(with: ProfileView, duration: 0.8, options: transitionOptions, animations: {
                self.ProfileView.isHidden = true
            })
            UIView.transition(with: LoginView, duration: 0.8, options: transitionOptions, animations: {
                self.LoginView.isHidden = false
            })
        }
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
