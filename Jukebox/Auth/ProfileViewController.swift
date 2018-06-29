//
//  ProfileViewController.swift
//  Jukebox
//
//  Created by Philipp on 20.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol CardDelegate { func editing(_ active: Bool) }

class ProfileViewController: UIViewController, CardDelegate {
    
    @IBOutlet weak var container: UIView!
    var info: InfoCardViewController?
    var edit: EditCardViewController?
    var delegate: CardDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addCardViews()
        self.setObservers()
    }
    
    func addCardViews() {
        self.info = self.storyboard?.instantiateViewController(withIdentifier: "infoCard") as? InfoCardViewController
        if let info = self.info {
            self.info?.delegate = self
            info.willMove(toParentViewController: self)
            container.addSubview(info.view)
            self.addChildViewController(info)
            info.view.frame = container.bounds
            info.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            info.didMove(toParentViewController: self)
            self.info?.view.isHidden = true
        }
        
        self.edit = self.storyboard?.instantiateViewController(withIdentifier: "editCard") as? EditCardViewController
        if let edit = self.edit {
            self.edit?.delegate = self
            edit.willMove(toParentViewController: self)
            container.addSubview(edit.view)
            self.addChildViewController(edit)
            edit.view.frame = container.bounds
            edit.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            edit.didMove(toParentViewController: self)
            self.edit?.view.isHidden = true
        }
    }
    
    func setObservers(){
        Auth.auth().addIDTokenDidChangeListener { (_, user) in
            guard let user = user else { return }
            self.info?.update(user)
            self.edit?.update(user)
            if let _ = user.displayName { self.editing(false) }
            else { self.editing(true) }
        }
    }
    
    func editing(_ active: Bool) {
        let transitionOptions: UIViewAnimationOptions = [.transitionFlipFromRight, .showHideTransitionViews]
        guard let info = info else {print("Info View not set"); return}
        guard let edit = edit else {print("Edit View not set"); return}
        if info.view.isHidden && edit.view.isHidden{
            if active {edit.view.isHidden = false}
            else {info.view.isHidden = false}
            return
        }
        if active{
            UIView.transition(with: info.view, duration: 0.8, options: transitionOptions, animations: { info.view.isHidden = true })
            UIView.transition(with: edit.view, duration: 0.8, options: transitionOptions, animations: { edit.view.isHidden = false })
        } else {
            UIView.transition(with: edit.view, duration: 0.8, options: transitionOptions, animations: { edit.view.isHidden = true })
            UIView.transition(with: info.view, duration: 0.8, options: transitionOptions, animations: { info.view.isHidden = false })
        }
        guard let user = Auth.auth().currentUser else { return }
        info.update(user)
        edit.update(user)
        self.delegate?.editing(active)
    }
    
    @IBAction func logout(_ sender: Any) {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        let logoutAction = UIAlertAction(title: "Disconnect", style: .destructive) { action in
            Auth.auth().signOut(completion: { (error) in
                if let error = error {print(error)}
            })
        }
        let alertController = UIAlertController(title: nil, message: "Do you really want to disconnect from Spotify ?", preferredStyle: .actionSheet)
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        self.present(alertController, animated: true)
    }
}
