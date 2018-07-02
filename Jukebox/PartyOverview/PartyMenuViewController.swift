//
//  PartyMenuViewController.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Firebase
import Firebase

class PartyMenuViewController: UIViewController {
    
    var partyID: String!
    var partyName: String!
    var partyHost: String!
    var ref: DatabaseReference!
    var user = Auth.auth().currentUser?.uid
    var shareMessage: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()
        shareMessage = "Welcome to the party \(partyName!)!\nThe host \(partyHost!) invited you to the party with the ID: \n \(self.partyID!)"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func sharePartyIDPressed(_ sender: ButtonDesignable) {
        let activity = UIActivityViewController(activityItems: [shareMessage], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        self.present(activity, animated: true, completion: nil)
    }
    
    @IBAction func deletePartyPressed(_ sender: ButtonDesignable) {
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete the party \(partyName!)", preferredStyle: .alert)
        let cancleAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
        let deleteParty = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.extinguishPartyFromFirebase()
        }
        
        alert.addAction(cancleAction)
        alert.addAction(deleteParty)
        present(alert, animated: true, completion: nil)
    }
    
    func extinguishPartyFromFirebase() {
        self.ref.child("/users/\(user!)/parties/\(partyID!)").setValue(nil)
    }
    
    @IBAction func dismissPopUp(_ sender: ButtonDesignable) {
        dismiss(animated: true, completion: nil)
    }
}
