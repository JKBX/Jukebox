//
//  LoginViewController.swift
//  Jukebox
//
//  Created by Philipp on 25.04.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseAuth
import SafariServices

class LoginViewController: UIViewController {
    
    var authSession: SFAuthenticationSession?
    @IBAction func authenticateSpotify(_ sender: Any) {
        //Grab URLs for App & Web Auth, get Redirect URL
        let webURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()!
        let redURL = SPTAuth.defaultInstance().redirectURL.absoluteString
    
        //Init Auth Session
        self.authSession = SFAuthenticationSession(url: webURL, callbackURLScheme: redURL) { (url:URL?, error:Error? ) in
            guard error == nil, let successURL = url else { print("Error Authenticating!"); return; }
            NotificationCenter.default.post(name: NSNotification.Name.loading, object:(true, "Signing in...", self))
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: successURL) { (error, session) in
                if let error = error { print(error); return }
                Auth.auth().signIn(with: session) { (user, error) in
                    if let error = error {print(error); return;}
                    NotificationCenter.default.post(name: NSNotification.Name.loading, object:(false, "", self))
                }
            }
        }
        self.authSession?.start()
    }
}
