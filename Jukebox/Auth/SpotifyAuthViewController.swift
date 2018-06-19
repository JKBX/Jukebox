//
//  ViewController.swift
//  test
//
//  Created by Philipp on 25.04.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseAuth
import SafariServices
import Alamofire

class SpotifyAuthViewController: UIViewController {
    
    //Spotify User Object, containing User Data, once authenticated \w Spotify
    var user: SPTUser?
    
    //Auth Session, needs to be held as class variable for allocation
    var authSession:SFAuthenticationSession?
    
    //Loading View
    var blurredBackgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLoadingView()
    
        //Check if User is already Authed
        if SPTAuth.defaultInstance().session != nil && SPTAuth.defaultInstance().session.isValid(){
            self.loading(active: true)
            NotificationCenter.default.addObserver(self, selector: #selector(successfulLogin), name: NSNotification.Name.Spotify.loggedIn, object: nil)
            self.receivedSession(session: SPTAuth.defaultInstance().session)
        }
    }
    
    func setupLoadingView() {
        blurredBackgroundView.frame = view.bounds
        /*let spinner = UIActivityIndicatorView()
        blurredBackgroundView.contentView.addSubview(spinner)
        spinner.hidesWhenStopped = true
        blurredBackgroundView.frame = view.frame
        spinner.center = blurredBackgroundView.center*/
    }
    
    func loading(active: Bool) -> Void {
        let spinner:UIActivityIndicatorView = self.blurredBackgroundView.contentView.subviews[0] as! UIActivityIndicatorView
        if active {
            spinner.startAnimating()
            view.addSubview(blurredBackgroundView)
            UIView.animate(withDuration: 0.5) {
                self.blurredBackgroundView.effect = UIBlurEffect(style: .dark)
            }
        } else {
            spinner.stopAnimating()
            UIView.animate(withDuration: 0.5, animations: {
                self.blurredBackgroundView.effect = nil
            }, completion: { (complete) in
                self.blurredBackgroundView.removeFromSuperview()
            })
            
        }
    }
    
    //Action on-tap Spotify Button, Opens SFAuthSession to Connect
    @IBAction func authenticateSpotify(_ sender: Any) {
        //Grab URLs for App & Web Auth, get Redirect URL
        let webURL = SPTAuth.defaultInstance().spotifyWebAuthenticationURL()!
        let redURL = SPTAuth.defaultInstance().redirectURL.absoluteString
    
        //Attach Login Observer
        NotificationCenter.default.addObserver(self, selector: #selector(successfulLogin), name: NSNotification.Name.Spotify.loggedIn, object: nil)
        
        //Authorization Completion Handler
        let handler:SFAuthenticationSession.CompletionHandler = { (callBack:URL?, error:Error? ) in
            //Check for Auth Session Errors
            guard error == nil, let successURL = callBack else { print("Error Authenticating!"); return; }
            
            //Grab Tokens from Response
            SPTAuth.defaultInstance().handleAuthCallback(withTriggeredAuthURL: successURL) { (error, session) in
                
                //Check if there is an error because then there won't be a session.
                if let error = error { print(error); return }
                //self.loading(active: true)
                
                //Login with received session
                self.receivedSession(session: session)
            }
        }
        
        //Init Auth Session
        self.authSession = SFAuthenticationSession(url: webURL, callbackURLScheme: redURL, completionHandler: handler)
        self.authSession?.start()
    }
    
    //Logging into the Spotify Streaming Controller
    func receivedSession(session: SPTSession?) -> Void {
        // Check if there is a session
        //self.loading(active: true)
        
        
        //Loading Overlay
        let alert = UIAlertController(title: nil, message: "Signing in...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        
        view.addSubview(blurredBackgroundView)
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        if let session = session {
            let headers: HTTPHeaders = [ "Authorization": "Bearer \(session.accessToken!)" ]
            Alamofire.request(URL(string: "https://jkbx-swapify.herokuapp.com/authenticate")!, method: .get, headers: headers).responseString { (response) in
                if let error = response.error { print(error); return }
                let JWToken = response.value!
                
                Auth.auth().signIn(withCustomToken: JWToken, completion: { (user, error) in
                     if error != nil {
                        print(error)
                        return
                     }
                     
                     print(user?.user.uid)
                     print(user?.user.displayName)
                     print(user?.user.email)
                     print(user?.user.photoURL)
                    
                    //self.loading(active: false)
                    self.dismiss(animated: true, completion: nil)
                    self.blurredBackgroundView.removeFromSuperview()
                    
                    //self.performSegue(withIdentifier: "flip", sender: self)
                    
                    if Auth.auth().currentUser != nil {
                        //self.dismiss(animated: true, completion: nil)
                        return
                    }
                })
            }
            
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: session.accessToken)
        }
    }
    
    //Observer function for Spotify Login, showing next view
    @objc func successfulLogin() {
        //Detach Login Observer
        NotificationCenter.default.removeObserver(self)
        print("logged in")
        
    }
    
    //Write User Data to Next View Controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createAccount" {
            let controller = segue.destination as! RegisterViewController
            controller.user = self.user
        }
        
        if segue.identifier == "loginAccount" {
            let controller = segue.destination as! LoginViewController
            controller.user = self.user
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
