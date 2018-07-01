//
//  PartyMenuViewController.swift
//  Jukebox
//
//  Created by Maximilian Babel on 01.07.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Firebase
import Firebase

class PartyMenuViewController: UIViewController {
    
    var ref: DatabaseReference!
    var user = Auth.auth().currentUser
    var shareMessage: String = "This is your PartyID: \n \(currentParty)"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sharePartyIDPressed(_ sender: ButtonDesignable) {
        let activity = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        self.present(activity, animated: true, completion: nil)
    }
    
    @IBAction func deletePartyPressed(_ sender: ButtonDesignable) {
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete the party \(currentParty)", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        let deleteParty = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.extinguishPartyFromFirebase()
        }
        
        alert.addAction(cancleAction)
        alert.addAction(deleteParty)
        present(alert, animated: true, completion: nil)
    }
    
    func extinguishPartyFromFirebase() {
        if(currentAdmin == false){
            self.ref.child("/users/\(user?.uid)/parties/\(currentParty)").setValue(nil)
        } else {
            print("Du bist Admin dieser Party!")
        }
    }
    
    @IBAction func dismissPopUp(_ sender: ButtonDesignable) {
        dismiss(animated: true, completion: nil)
    }
}
