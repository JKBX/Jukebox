//
//  PopUpViewViewController.swift
//  Jukebox
//
//  Created by Maximilian Babel on 26.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit

class PopUpViewViewController: UIViewController {

    @IBOutlet weak var popUp: UIView!
    @IBOutlet weak var checkButton: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popUp.layer.cornerRadius = 10
        pulsate(checkButton: self.checkButton)
    }
    
    func pulsate(checkButton: UIImageView){
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 1
        pulse.fromValue = 0.9
        pulse.toValue = 1.1
        pulse.initialVelocity = 0.2
        
        checkButton.layer.add(pulse, forKey: "pulse")
    }
    
    @IBAction func dismissPopUp(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
