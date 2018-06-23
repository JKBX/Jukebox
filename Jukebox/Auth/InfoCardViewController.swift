//
//  InfoCardViewController.swift
//  Jukebox
//
//  Created by Philipp on 21.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

class InfoCardViewController: UIViewController {
    
    var delegate: CardDelegate?

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var picture: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        
        Auth.auth().addIDTokenDidChangeListener { (auth, _) in
            if auth.currentUser != nil {
                self.name.text = auth.currentUser?.displayName
                self.username.text = auth.currentUser?.uid
                self.picture.kf.setImage(with: Auth.auth().currentUser?.photoURL, options: [.processor(CenteredSquareProcessor())])
                self.picture.layer.masksToBounds = true
                self.picture.layer.cornerRadius = 64.0
                
                //self.picture.kf.setImage(with: auth.currentUser?.photoURL)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
