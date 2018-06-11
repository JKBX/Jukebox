//
//  UserProfileViewController.swift
//  Jukebox
//
//  Created by Philipp on 08.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var SpotifyView: UIView!
    @IBOutlet weak var FirebaseView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func expand(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.FirebaseView.frame.size.height += self.view.frame.height - 40//100
            
            self.SpotifyView.frame.origin.y += 100
        })
    }
    
    @IBAction func collapse(_ sender: Any) {
        UIView.animate(withDuration: 1, animations: {
            self.FirebaseView.frame.size.height -= 100
            self.SpotifyView.frame.origin.y -= 100
        })
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
