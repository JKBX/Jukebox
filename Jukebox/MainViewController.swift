//
//  MainViewController.swift
//  test
//
//  Created by Philipp on 27.04.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseAuth
import VolumeBar

class MainViewController: UINavigationController {

    @IBOutlet weak var naviBar: UINavigationBar!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if SPTAuth.defaultInstance().session == nil || Auth.auth().currentUser == nil{
            DispatchQueue.main.async { self.performSegue(withIdentifier: "showLogin", sender: self) }
        }

        
        volumeBar()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
/*
 setting for the volumeBar
 */
extension MainViewController{
    func volumeBar(){
        let volumeBar = VolumeBar.shared
        var customStyle = VolumeBarStyle.rightOfNotch
        customStyle.trackTintColor = .white
        customStyle.progressTintColor = .black
        customStyle.backgroundColor = .init(red: 0, green: 0, blue: 0, alpha: 0)

        volumeBar.style = customStyle
        volumeBar.start()
    }
}


