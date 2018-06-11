//
//  FirebaseProfileViewController.swift
//  Jukebox
//
//  Created by Philipp on 08.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class FirebaseProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Firebase Profile Did Load")
        // Do any additional setup after loading the view.
    }

    @IBAction func edit(_ sender: Any) {
        //self.performSegue(withIdentifier: "edit", sender: self)
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
