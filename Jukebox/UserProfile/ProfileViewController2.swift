//
//  ProfileViewController.swift
//  Jukebox
//
//  Created by Philipp on 09.05.18.
//  Copyright © 2018 Philipp. All rights reserved.
//
/*
import UIKit
import FirebaseAuth
import Kingfisher

class ProfileViewController: UIViewController {

    @IBOutlet weak var ViewTwo: UIView!
    @IBOutlet weak var ViewOne: UIView!
    @IBOutlet weak var helperUrl: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var spotifyUserName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        super.viewDidLoad()
        
        //firstView = UIView(frame: CGRect(x: 32, y: 32, width: 128, height: 128))
        //secondView = UIView(frame: CGRect(x: 32, y: 32, width: 128, height: 128))
        
        //firstView.backgroundColor = UIColor.red
        //secondView.backgroundColor = UIColor.blue
        
        ViewTwo.isHidden = true
        
        //view.addSubview(ViewOne)
        //view.addSubview(ViewTwo)
        
        //perform(#selector(flip), with: nil, afterDelay: 2)

        /*let user = Auth.auth().currentUser
        print(user)
        
         //TODO change password
         
        print(Auth.auth().currentUser)
        print("Debug Descr")
        print(Auth.auth().currentUser.debugDescription)
        print("Dispname")
        print(Auth.auth().currentUser?.displayName)*/
        email.text = Auth.auth().currentUser?.email
        
        userName.text = Auth.auth().currentUser?.displayName
        
        
        // Load Image, crop centered square and round corners
        let processor = CenteredSquareProcessor()
        profilePicture.kf.setImage(with: Auth.auth().currentUser?.photoURL, options: [.processor(processor)])
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = 64.0
        
        print(Auth.auth().currentUser?.photoURL?.absoluteString)
    
        helperUrl.text = Auth.auth().currentUser?.photoURL?.absoluteString
        
        /*
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
 */
        /*print("Metadata")
        print(Auth.auth().currentUser?.metadata)
        print("Photo url")
        print(Auth.auth().currentUser?.photoURL)
        print("Provider Data")
        print(Auth.auth().currentUser?.providerData)
        print("ProviderID")
        print(Auth.auth().currentUser?.providerID)*/
        
        //TODO move to profile creation
        /*let profileChange = Auth.auth().currentUser?.createProfileChangeRequest()
        profileChange?.photoURL = URL(string: "https://profile-images.scdn.co/images/userprofile/default/97593639d5f19e6ed23e2f85c780138768384315")
        profileChange?.commitChanges(completion: { (error) in
            if error != nil {
                print(error)
                return
            }
            print("Success")
        })*/
        
        SPTUser.requestCurrentUser(withAccessToken:(SPTAuth.defaultInstance().session.accessToken), callback: { (error, data) in
            guard let user = data as? SPTUser else { print("Couldn't cast as SPTUser"); return }
            print(user.displayName)
            print(user.canonicalUserName)
            self.spotifyUserName.text = "Connected to Spotify User \(String(user.canonicalUserName))"
        })
        //
        // Do any additional setup after loading the view.
    }
    
    @IBAction func flip(_ sender: Any) {
        
        
        
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        UIView.transition(with: ViewOne, duration: 0.8, options: transitionOptions, animations: {
            self.ViewOne.isHidden = true
        })
        
        UIView.transition(with: ViewTwo, duration: 0.8, options: transitionOptions, animations: {
            self.ViewTwo.isHidden = false
        })
    }
    
    @IBAction func logout(_ sender: Any) {
        do {try Auth.auth().signOut()}
        catch let signOutError as NSError {  print ("Error signing out: %@", signOutError) }
    }
    
    @IBAction func disconnectSpotify() -> Void {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        let logoutAction = UIAlertAction(title: "Disconnect", style: .destructive) { action in
            SPTAudioStreamingController.sharedInstance().logout()
            SPTAuth.defaultInstance().session = nil
            UserDefaults.standard.removeObject(forKey: SpotifyConfig.sessionKey)
            //self.performSegue(withIdentifier: "showLogin", sender: self)
            //TODO notify logout
            self.dismiss(animated: true, completion: nil)
        }
            
        let alertController = UIAlertController(title: nil, message: "Do you really want to disconnect from Spotify ?", preferredStyle: .actionSheet)
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        self.present(alertController, animated: true)
    }

    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
*/
