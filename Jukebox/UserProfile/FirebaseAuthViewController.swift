//
//  FirebaseAuthViewController.swift
//  Jukebox
//
//  Created by Philipp on 10.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth

class FirebaseAuthViewController: UIViewController {

    lazy var LoginView: FirebaseLoginViewController = {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "FirebaseLogin") as! FirebaseLoginViewController
        
        
        //viewController.delegate = self
        addViewControllerAsChildView(child: viewController)
        
        return viewController
    }()
    
    lazy var ProfileView: FirebaseProfileViewController = {
        let storyboard = UIStoryboard(name: "UserProfile", bundle: Bundle.main)
        
        let viewController = storyboard.instantiateViewController(withIdentifier: "FirebaseProfile") as! FirebaseProfileViewController
        
        addViewControllerAsChildView(child: viewController)
        
        return viewController
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Auth.auth().currentUser.lin
        LoginView.view.isHidden = true
        ProfileView.view.isHidden = false
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("Profile Will appear")
    }

    private func addViewControllerAsChildView(child viewController: UIViewController){
        addChildViewController(viewController)
        
        view.addSubview(viewController.view)
        
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    @IBAction func switchViews(_ sender: Any) {
        LoginView.view.isHidden = !(LoginView.view.isHidden)
        ProfileView.view.isHidden = !(ProfileView.view.isHidden)
        
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
