//
//  PartyPlaylistViewController.swift
//  Jukebox
//
//  Created by Philipp on 22.05.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PartyPlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Vars
    
    var ref: DatabaseReference! = Database.database().reference()
    var isAdmin: Bool = false
    var partyID: String = ""
    var queue: [NSDictionary] = []
    let user = Auth.auth().currentUser
    
    //MARK: LifeCycle
    var party:NSDictionary = [:]
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        let queueObserver = ref.child("/Paries/\(self.partyID)/Queue").observe(DataEventType.value, with: { (snapshot) in
            self.queue = snapshot.value as! [NSDictionary]
        })
        super.viewDidLoad()
        print(party)
        label.text = party.value(forKey: "Name") as! String
        // Do any additional setup after loading the view.
    }
    
    //MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        cell.songTitleLabel.text = queue[indexPath.item].value(forKey: "Name") as? String
        cell.songArtistLabel.text = queue[indexPath.item].value(forKey: "Artist") as? String
        cell.delegate = self as? TrackCellDelegate
        cell.likeButton.setImage(#imageLiteral(resourceName: "round_star_border_black_18dp-1"), for: UIControlState.normal)
        return cell
    }
    
    @IBAction func likeTrack(_sender: UIButton){
        if let user = user{
            let uid = user.uid
        
            ref.child("/Paries/\(self.partyID)/Queue/Track/Votes").observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(uid){
                    self.ref.child(uid).removeValue()
//                    likeButton.setImage(#imageLiteral(resourceName: "round_star_border_black_18dp-1"), for: UIControlState.normal)
                    print("unliked track")
                }else{
                    self.ref.setValue(uid)
//                  cell.likeButton.setImage(#imageLiteral(resourceName: "round_star_black_18dp-1"), for: UIControlState.normal)
                    print("liked track")
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: TrackCellDelegate{
    func likedTrack(trackID: String) {
        
    }
}






