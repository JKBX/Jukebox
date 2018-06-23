//
//  ProfileViewController.swift
//  Jukebox
//
//  Created by Philipp on 20.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController, CardDelegate {
    
    @IBOutlet weak var infoCard: InfoCardViewController!
    @IBOutlet weak var editCard: EditCardViewController!
    @IBOutlet weak var editButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoCard.delegate = self
        editCard.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if Auth.auth().currentUser?.displayName == nil{
            self.editing(true)
        }
    }
    
    @IBAction func switchEditing(_ sender: Any) {
        self.editing(editCard.isHidden)
    }
    
    func editing(_ active: Bool) {
        //TODO switch title
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        
        if active{
            UIView.transition(with: infoCard, duration: 0.8, options: transitionOptions, animations: {
                self.infoCard.isHidden = true
            })
            UIView.transition(with: editCard, duration: 0.8, options: transitionOptions, animations: {
                self.editCard.isHidden = false
            })
        } else {
            UIView.transition(with: editCard, duration: 0.8, options: transitionOptions, animations: {
                self.editCard.isHidden = true
            })
            UIView.transition(with: infoCard, duration: 0.8, options: transitionOptions, animations: {
                self.infoCard.isHidden = false
            })
        }
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
