//
//  PartyPlaylistViewController.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PartyPlaylistViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference! = Database.database().reference()
    var isAdmin: Bool = false
    var partyID: String = ""
    var trackID: String = ""
    var queue: [NSDictionary] = []
    let user = Auth.auth().currentUser
    

    
    //MARK: LifeCycle
    var party:NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queueObserver = ref.child("/parties/\(self.partyID)/queue").observe(DataEventType.value, with: { (snapshot) in
            self.queue = snapshot.value as! [NSDictionary]
        })
        tableView.dataSource = self

    }
    
    //MARK: TableView Methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return queue.count
//    }
/*
 Creating a tableView. Returns a cell with songTitleLabel and songArtistLabel
     
 */
 
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
////        Title < Artist < Counter
//        cell.titleArtistCounterLabels = cell.titleArtistCounterLabels.sorted{ $0.tag < $1.tag }
//        cell.titleArtistCounterLabels[0].text = queue[indexPath.item].value(forKey: "songTitle") as? String
//        cell.titleArtistCounterLabels[1].text = queue[indexPath.item].value(forKey: "artist") as? String
//        //        TODO: vote tracks
//
//        cell.delegate = self as? TrackCellDelegate
//        cell.likeButton.setImage(#imageLiteral(resourceName: "round_star_border_black_18dp-1"), for: UIControlState.normal)
//        return cell
//    }
    
    
/*  Up- and downvote track.
     
     */
    
    @IBAction func likeTrack(_sender: UIButton){
        if let user = user{
            let uid = user.uid
            let treeVote = ref.child("/parties/\(self.partyID)/queue/\(self.trackID)/votes")
            
            treeVote.observeSingleEvent(of: .value, with: { (snapshot) in
                if snapshot.hasChild(uid){
                    treeVote.child(uid).setValue(false)
//                   likeButton.setImage(#imageLiteral(resourceName: "round_star_border_black_18dp-1"), for: UIControlState.normal)
                    print("unliked track")
                    self.tableView.reloadData()
                }else{
                    treeVote.child(uid).setValue(true)
//                  cell.likeButton.setImage(#imageLiteral(resourceName: "round_star_black_18dp-1"), for: UIControlState.normal)
                    print("liked track")
                    self.tableView.reloadData()
                }
            })
        }else{
            print("error no user at firebase")
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//extension ViewController: TrackCellDelegate{
//    func likedTrack(trackID: String) {
//
//    }
//
//}


extension PartyPlaylistViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //          cell as TrackCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
            //       cellLabels[] tag order -> [Title,Artist,Counter] -> [0,1,2]
                var cellLabels = cell.titleArtistCounterLabels.sorted{ $0.tag < $1.tag }
                cellLabels[0].text = queue[indexPath.item].value(forKey: "songTitle") as? String
                cellLabels[1].text = queue[indexPath.item].value(forKey: "artist") as? String
                cellLabels[2].text = queue[indexPath.item].value(forKey: "voteCount") as? String
                cell.likeButton.setImage(#imageLiteral(resourceName: "round_star_border_black_18dp-1"), for: UIControlState.normal)
        
        
                cell.delegate = self as? TrackCellDelegate
        
                return cell
    }
}




