//
//  ProfileViewController.swift
//  Jukebox
//
//  Created by Philipp on 20.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logout(_ sender: Any) {
        print("lgout")
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        let logoutAction = UIAlertAction(title: "Disconnect", style: .destructive) { action in
            do {try Auth.auth().signOut()}
            catch let signOutError as NSError {  print ("Error signing out: %@", signOutError) }
            SPTAudioStreamingController.sharedInstance().logout()
            SPTAuth.defaultInstance().session = nil
            UserDefaults.standard.removeObject(forKey: SpotifyConfig.sessionKey)
        }
        
        let alertController = UIAlertController(title: nil, message: "Do you really want to disconnect from Spotify ?", preferredStyle: .actionSheet)
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        self.present(alertController, animated: true)
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
