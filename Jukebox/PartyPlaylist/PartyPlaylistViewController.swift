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

class PartyPlaylistViewController: UIViewController{ //PlayerDelegate
    
    //MARK: Vars
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference! = Database.database().reference()
    var miniPlayer: MiniPlayerViewController?
    //var currentSong: TrackModel?
    //var partyID: String = ""
    //var queue: [TrackModel] = []
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search))
        navigationItem.rightBarButtonItem = button
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentQueue = []
        //TODO fix back/forth bug
        self.tableView.reloadData()
        self.ref = Database.database().reference().child("/parties/\(currentParty!)")
        setupObservers()
    }
    
    //TODO ??
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MiniPlayerViewController {
            
            miniPlayer = destination
            miniPlayer?.delegate = self
            
            print("func call prepare MINIPLAYER")
            
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        //TODO test if viewDidDisappear is right
        //Reset Global Vars
        //currentParty = nil
        //currentTrack = nil
        //currentQueue = []
        freeObservers()
    }
    
    
   
    
  
    
    //MARK: Observer-Methods
    
    func setupObservers() {
        ref.child("/queue").observe(.childChanged, with: { (snapshot) in self.onChildChanged(TrackModel(from: snapshot))})
        ref.child("/queue").observe(.childAdded, with: { (snapshot) in self.onChildAdded(TrackModel(from: snapshot))})
        ref.child("/queue").observe(.childRemoved, with: { (snapshot) in self.onChildRemoved(TrackModel(from: snapshot))})

        ref.child("/currentlyPlaying").observe(.value, with: { (snapshot) in self.onCurrentTrackChanged(snapshot)})
    }
    
    
    /*TODO fix ordering*/
    func onChildAdded(_ changedTrack: TrackModel) {
        //Todo test if only called on vote
        currentQueue.append(changedTrack)
        currentQueue = currentQueue.sorted() { $0.voteCount > $1.voteCount }
        let index = currentQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        
        self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: UITableViewRowAnimation.automatic)
    }
    
    func onChildChanged(_ changedTrack: TrackModel) {
        
        let index = currentQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        currentQueue[index] = changedTrack
        self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        
        
        let sortedQueue = currentQueue.sorted() { $0.voteCount > $1.voteCount }
        let newIndex = sortedQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        
        if newIndex != index {
            print("Moving from \(String(index)) to \(String(newIndex))")
            self.tableView.moveRow(at: IndexPath(item: newIndex, section: 0), to: IndexPath(item: index, section: 0))
            currentQueue = sortedQueue
        }
    }
    
    
    func onChildRemoved(_ changedTrack: TrackModel) {
        //Todo test if only called on vote
        let index = currentQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        currentQueue.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: UITableViewRowAnimation.left)
    }
    
    
    func onCurrentTrackChanged(_ snapshot: DataSnapshot) {
        currentTrack = snapshot.exists() ? TrackModel(from: snapshot) : nil
        miniPlayer?.setting()
    }
    
    //Helper function finding a changed Track in the existing queue
    func getIndex(of findTrack: TrackModel) -> Int {
        return currentQueue.index(where: { (track) -> Bool in track.trackId == findTrack.trackId })!
    }
    
    
    @objc func search(){
        self.performSegue(withIdentifier: "showSearch", sender: self)
    }
    
    func freeObservers(){
        ref.removeAllObservers()
        self.ref = Database.database().reference()
    }
}


extension PartyPlaylistViewController: PlayerDelegate{
    func expandSong() {
       
        guard let expandedTrackCard = UIStoryboard(name: "UIPlayer", bundle: nil).instantiateViewController(withIdentifier: "ExpandedTrackViewController")
            as? ExpandedTrackViewController else {
                assertionFailure("No view controller ID ExpandedTrackViewController in this storyboard found")
                return
        }
        expandedTrackCard.backingPic = view.makeScreenshot(true)
        expandedTrackCard.sourceView = miniPlayer
        present(expandedTrackCard, animated: false)
    }
}

// Screenshot for Expanded Player Background
extension UIView  {
    func makeScreenshot(_ fullScreen: Bool) -> UIImage? {
        if fullScreen {
            let layer = UIApplication.shared.keyWindow!.layer
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
            layer.render(in: UIGraphicsGetCurrentContext()!)
        } else {
            UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        let screen = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screen
    }
}


// MARK: Table View Extensions
extension PartyPlaylistViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentQueue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = currentQueue[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackWithImage", for: indexPath) as! TrackCell
        cell.setup(from: track)
        cell.partyRef = self.ref
        return cell
    }
}

extension PartyPlaylistViewController: UITableViewDelegate{
    
    //Set Custom Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 64.0;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let track = currentQueue[indexPath.item]
        if !currentAdmin{
            return UISwipeActionsConfiguration(actions: [])
        }
        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let alert = UIAlertController(title: "Are you sure you want to remove \(track.songName!)?", message: "This track had \(String(track.voteCount)) votes.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.ref.child("/parties/\(currentParty!)/queue/\(track.trackId as String)").removeValue()
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
        
        let track = currentQueue[indexPath.item]
        
        let voteAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            success(true)
            if track.liked{
                //Unlike
                self.ref.child("/parties/\(currentParty!)/queue/\(track.trackId as String)/votes").child(self.userID!).removeValue()
            } else {
                //Like
                self.ref.child("/parties/\(currentParty!)/queue/\(track.trackId as String)/votes").child(self.userID!).setValue(true)
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
