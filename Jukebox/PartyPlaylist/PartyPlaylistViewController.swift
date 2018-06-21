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

class PartyPlaylistViewController: UIViewController {
    
//MARK: Vars
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference! = Database.database().reference()
    var isAdmin: Bool = false
    var partyID: String = ""
    var queue: [TrackModel] = []
    let userID = Auth.auth().currentUser?.uid
    
//MARK: LifeCycle
    var party:NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search))
        navigationItem.rightBarButtonItem = button
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSearch" {
            let controller = segue.destination as! SearchViewController
            controller.partyID = self.partyID
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.ref = ref.child("/parties/\(self.partyID)")
        setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        freeObservers()
    }
    
//MARK: Observer-Methods
    
    func setupObservers() {
        ref.child("/queue").observe(.childChanged, with: { (snapshot) in self.onChildChanged(changedTrack: TrackModel(from: snapshot))})
        ref.child("/queue").observe(.childAdded, with: { (snapshot) in self.onChildAdded(changedTrack: TrackModel(from: snapshot))})
        ref.child("/queue").observe(.childRemoved, with: { (snapshot) in self.onChildRemoved(changedTrack: TrackModel(from: snapshot))})
    }
    
    func onChildChanged(changedTrack: TrackModel) {
        //Todo test if only called on vote
        let index = self.queue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        self.queue[index] = changedTrack
        self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        
        
        let sortedQueue = self.queue.sorted() { $0.voteCount > $1.voteCount }
        let newIndex = sortedQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        
        if newIndex != index {
            print("Moving from \(String(index)) to \(String(newIndex))")
            self.tableView.moveRow(at: IndexPath(item: newIndex, section: 0), to: IndexPath(item: index, section: 0))
            self.queue = sortedQueue
        }
    }
    
    func onChildAdded(changedTrack: TrackModel) {
        //Todo test if only called on vote
        self.queue.append(changedTrack)
        self.queue = self.queue.sorted() { $0.voteCount > $1.voteCount }
        let index = self.queue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        
        self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: UITableViewRowAnimation.automatic)
    }
    
    func onChildRemoved(changedTrack: TrackModel) {
        //Todo test if only called on vote
        let index = self.queue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        self.queue.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: UITableViewRowAnimation.left)
    }
    
    func freeObservers(){
        ref.removeAllObservers()
        self.ref = Database.database().reference()
    }
    
    @objc func search(){
        print("Search")
        /*let trackId = "6b6tRqejukUAsb2h7SvYrG"
        let newTrack: NSDictionary = [
            "albumTitle": "Party With Guns",
            "artist" : "Southpaw Swagger",
            "coverURL" : "https://i.scdn.co/image/6206ccce86a8921d85c194c8f28830f5583c5c5c",
            "songTitle" : "Make The Party Loud",
            "votes" : [
            "84Duvpn3IXYenfJRgjSsy6ddbmC3" : "true"
        ]
        ]
        self.ref.child("/parties/\(self.partyID)/queue/\(trackId as! String)").setValue(newTrack)*/
        
        self.performSegue(withIdentifier: "showSearch", sender: self)
    }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

//MARK: Data Source

extension PartyPlaylistViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = queue[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackWithImage", for: indexPath) as! TrackCell
        cell.setup(from: track)
        cell.partyRef = self.ref.child("/parties/\(self.partyID)")
        return cell
    }
}

//MARK: View Delegate

extension PartyPlaylistViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 64.0;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let track = self.queue[indexPath.item]
        if !isAdmin{
            return UISwipeActionsConfiguration(actions: [])
        }
        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let alert = UIAlertController(title: "Are you sure you want to remove \(track.songName as! String)?", message: "This track had \(String(track.voteCount)) votes.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.ref.child("/parties/\(self.partyID)/queue/\(track.trackId as String)").removeValue()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            success(true)
        })
        modifyAction.title = "Remove"
        modifyAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [modifyAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let track = self.queue[indexPath.item]
        
        let voteAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            success(true)
            if track.liked{
                //Unlike
                self.ref.child("/parties/\(self.partyID)/queue/\(track.trackId as String)/votes").child(self.userID!).removeValue()
            } else {
                //Like
                self.ref.child("/parties/\(self.partyID)/queue/\(track.trackId as String)/votes").child(self.userID!).setValue(true)
            }
        })
        voteAction.image = UIImage(named: track.liked ? "favorite" : "favoriteOutline")
        voteAction.backgroundColor = UIColor(named: "SolidBlue400")
        return UISwipeActionsConfiguration(actions: [voteAction])
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //TODO center
        let label = UILabel()
        label.text = "The Show must go on! Keep adding Tracks."
        label.font.withSize(8)
        label.textColor = .white
        return label
    }
}
