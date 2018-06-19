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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ProfileView.isHidden = true
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        Auth.auth().addIDTokenDidChangeListener { (auth, _) in
            print(auth.currentUser)
            if auth.currentUser != nil {
                self.done.isEnabled = true
                self.switchView(to: "profileView")
            } else {
                self.done.isEnabled = false
                self.switchView(to: "loginView")
            }
        }

        // Do any additional setup after loading the view.
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
