//
//  AuthViewController.swift
//  Jukebox
//
//  Created by Philipp on 28.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthViewController: UIViewController, CardDelegate {

    var login: LoginViewController?
    var profile: ProfileViewController?
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var done: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCardViews()
        self.attachAuthObservers()
    }
    
    func addCardViews() {
        self.login = self.storyboard?.instantiateViewController(withIdentifier: "login") as? LoginViewController
        if let login = self.login {
            login.willMove(toParentViewController: self)
            container.addSubview(login.view)
            self.addChildViewController(login)
            login.view.frame = container.bounds
            login.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            login.didMove(toParentViewController: self)
            self.login?.view.isHidden = true
        }
        
        self.profile = self.storyboard?.instantiateViewController(withIdentifier: "profile") as? ProfileViewController
        if let profile = self.profile {
            self.profile?.delegate = self
            profile.willMove(toParentViewController: self)
            container.addSubview(profile.view)
            self.addChildViewController(profile)
            profile.view.frame = container.bounds
            profile.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            profile.didMove(toParentViewController: self)
            self.profile?.view.isHidden = true
        }
    }
    
    func attachAuthObservers() {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        guard let login = login else {print("Login View not set"); return}
        guard let profile = profile else {print("Profile View not set"); return}
        Auth.auth().addIDTokenDidChangeListener { (auth, _) in
            if let _ = auth.currentUser {
                self.title = "Profile"
                self.done.isEnabled = true
                if login.view.isHidden && profile.view.isHidden{ profile.view.isHidden = false; return}
                UIView.transition(with: login.view, duration: 0.8, options: transitionOptions, animations: {
                    login.view.isHidden = true
                })
                UIView.transition(with: profile.view, duration: 0.8, options: transitionOptions, animations: {
                    profile.view.isHidden = false
                })
            } else {
                self.title = "Login"
                self.done.isEnabled = false
                if login.view.isHidden && profile.view.isHidden{ login.view.isHidden = false; return}
                UIView.transition(with: profile.view, duration: 0.8, options: transitionOptions, animations: {
                    profile.view.isHidden = true
                })
                UIView.transition(with: login.view, duration: 0.8, options: transitionOptions, animations: {
                    login.view.isHidden = false
                })
            }
        }
    }
    
    func editing(_ active: Bool) {
        done.isEnabled = !active
    }
    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
