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
    var blurredBackgroundView = UIVisualEffectView()
    
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
    
    func setupLoadingView() -> Void {
        let spinner = UIActivityIndicatorView()
        blurredBackgroundView.contentView.addSubview(spinner)
        spinner.hidesWhenStopped = true
        blurredBackgroundView.frame = view.frame
        spinner.center = blurredBackgroundView.center
    }
    
    func loading(active: Bool) -> Void {
        let spinner:UIActivityIndicatorView = self.blurredBackgroundView.contentView.subviews[0] as! UIActivityIndicatorView
        if active{
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
                self.loading(active: true)
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
        self.loading(active: true)
        if let session = session {
            let uid = session.canonicalUsername
            print(uid)
            //Alamofire.get
            
            /*Alamofire.request("http://localhost:4343/jwt",
                              parameters: ["uid": uid!]).responseString { (JWT) in
                                print(JWT)
            }*/
            
            /*Alamofire.request("localhost:4343/jwt?uid=\(uid!)").responseJSON { response in
                print("Request: \(String(describing: response.request))")   // original url request
                print("Response: \(String(describing: response.response))") // http url response
                print("Result: \(response.result)")                         // response serialization result
                
                if let json = response.result.value {
                    print("JSON: \(json)") // serialized json response
                }
                
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)") // original server data as UTF8 string
                }
            }*/
            
            SPTAudioStreamingController.sharedInstance().login(withAccessToken: session.accessToken)
        }
    }
    
    //Observer function for Spotify Login, showing next view
    @objc func successfulLogin() {
        //Detach Login Observer
        NotificationCenter.default.removeObserver(self)
        print("logged in")
        SPTUser.requestCurrentUser(withAccessToken:(SPTAuth.defaultInstance().session.accessToken), callback: { (error, data) in
            guard let user = data as? SPTUser else { print("Couldn't cast as SPTUser"); return }
            self.user = user
            print(user)
            print(user.largestImage.imageURL.absoluteString)
            
            let token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwaGlsaXBwYWx0bWFubiIsImlhdCI6MTUyODY0MzI2OCwiZXhwIjoxNTI4NjQ2ODY4LCJhdWQiOiJodHRwczovL2lkZW50aXR5dG9vbGtpdC5nb29nbGVhcGlzLmNvbS9nb29nbGUuaWRlbnRpdHkuaWRlbnRpdHl0b29sa2l0LnYxLklkZW50aXR5VG9vbGtpdCIsImlzcyI6ImZpcmViYXNlLWFkbWluc2RrLWE4azNnQGp1a2Vib3gtaW9zLmlhbS5nc2VydmljZWFjY291bnQuY29tIiwic3ViIjoiZmlyZWJhc2UtYWRtaW5zZGstYThrM2dAanVrZWJveC1pb3MuaWFtLmdzZXJ2aWNlYWNjb3VudC5jb20ifQ.BcJ7n84KqvpGALPRn5KlLHhFJsnqwyRwsLJCnqbtHjscAtSGuNbAUuxcKiCyRi6Ge1cOQMcrwc49LX4LB7epi_68KsIJrSBuULYEYv389Gs5Ot5htjA5lifsl5U8cG7pFzYFS51kKN_y2tWAD8Z8WTAgv2Z43KaehaEP-tlkAOec7fPe_OFqsr-zPxGdKys3FydqG5cxrsAN-WxvnbbWlQsXUeUGKIk_Z6zyiYZqgTwBo06tHdwBxBTYTmCRde6JgVvyYu0d1jSVqjGh4WBhXymmLkHvs1rBqAw0cIJ0MnjoydFs-cK4Ynr4-yAwT-aDts_UDoCep84dZ9l3FJVVFA"
            Auth.auth().signIn(withCustomToken: token, completion: { (user, error) in
                if error != nil {
                    print(error)
                    return
                }
                
                print(user?.user.uid)
                print(user?.user.displayName)
                print(user?.user.email)
                print(user?.user.photoURL)
                print(user?.additionalUserInfo)
            })
            
            /*if Auth.auth().currentUser != nil {
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            Auth.auth().fetchProviders(forEmail: user.emailAddress) { providers, error in
                
                self.loading(active: false)
                
                //Check for Errors
                if let error = error { print(error); return }
                
                //Determine wheater account has already been, or needs to be created
                let nextView = (providers != nil) ? ("loginAccount") : ("createAccount")
                self.performSegue(withIdentifier: nextView, sender: self)
            }*/
        })
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
