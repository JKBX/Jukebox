//
//  PartyMenuViewController.swift
//  Jukebox
//
//  Created by Maximilian Babel on 01.07.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class PartyMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissPopUp(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
