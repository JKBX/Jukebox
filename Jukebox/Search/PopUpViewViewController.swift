//
//  PopUpViewViewController.swift
//  Jukebox
//
//  Copyright © 2018 Jukebox. All rights reserved.


import UIKit

class PopUpViewViewController: UIViewController {

    @IBOutlet weak var popUp: UIView!
    @IBOutlet weak var checkButton: UIImageView!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pulsate(checkButton: self.checkButton)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func pulsate(checkButton: UIImageView){
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 2
        pulse.fromValue = 0.1
        pulse.toValue = 1.0
        pulse.initialVelocity = 0.2
        
        checkButton.layer.add(pulse, forKey: "pulse")

    }
    
    @IBAction func dismissPopUp(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
