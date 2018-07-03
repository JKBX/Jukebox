//
//  PartyMenuViewController.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import Spartan

class PartyMenuViewController: UIViewController {
    
    var partyID: String!
    var partyName: String!
    var partyHost: String!
    var ref: DatabaseReference!
    var user = Auth.auth().currentUser?.uid
    var shareMessage: String!
    @IBOutlet weak var playlistButton: UIButton!

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
    
    @IBAction func writePlaylistToSpotify(_ sender: Any){
        playlistButton.isEnabled = false
        playlistButton.setTitle("Creating playlist ...", for: .disabled)
        playlistButton.setTitleColor(.green, for: .disabled)
        self.ref.child("/parties/\(partyID!)/history").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let session = SPTAuth.defaultInstance().session{
                let history = snapshot.value as! NSDictionary
                    var tracks: [String] = [""];
                    for track in history.allKeys as! [String] {
                        tracks.append("spotify:track:\(track)")
                    }
                    tracks.remove(at: 0)
                print(history.allKeys)
                    Spartan.authorizationToken = session.accessToken
                    _ = Spartan.createPlaylist(userId: self.user!, name: self.partyName, isPublic: true, isCollaborative: false, success: { (playlist: Playlist) in
                        _ = Spartan.addTracksToPlaylist(userId: self.user!, playlistId: playlist.id as! String, trackUris: tracks, success: { (snapshot) in
                            self.playlistButton.isEnabled = true
                            self.playlistButton.setTitle("Save Party as Spotify Playlist", for: .normal)
                        }, failure: { (error) in print(error)})
                    }, failure: { (error) in print(error)})
                }
            }
        }
    }
    
    @IBAction func dismissPopUp(_ sender: ButtonDesignable) {
        dismiss(animated: true, completion: nil)
    }
}
