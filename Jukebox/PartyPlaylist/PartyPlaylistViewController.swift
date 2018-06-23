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

class PartyPlaylistViewController: UIViewController, TrackSubscriber{
    
    
    
    //MARK: Vars
    
    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference! = Database.database().reference()
    var miniPlayer: MiniPlayerViewController?
    var currentSong: TrackModel?
    var isAdmin: Bool!
    var partyID: String = ""
    var queue: [TrackModel] = []
    let userID = Auth.auth().currentUser?.uid
    
    /*   15.06.2018 - Chris
     
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MiniPlayerViewController {
            
            miniPlayer = destination
            miniPlayer?.delegate = self
            miniPlayer?.partyID = partyID
            miniPlayer?.isAdmin = isAdmin

            print("func call prepare MINIPLAYER")
    
        }
    }
    
    //MARK: LifeCycle
    var party:NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search))
        navigationItem.rightBarButtonItem = button
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.queue = []
        self.tableView.reloadData()
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
    
    func onChildAdded(changedTrack: TrackModel) {
        self.queue.append(changedTrack)
        self.queue = self.queue.sorted() { $0.voteCount > $1.voteCount }
        let index = getIndex(of: changedTrack)
        self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
    }
    
    func onChildChanged(changedTrack: TrackModel) {
        //Update Votes
        let index = getIndex(of: changedTrack)
        self.queue[index] = changedTrack
        self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)
        
        //Reorder Cell
        let sortedQueue = self.queue.sorted() { $0.voteCount > $1.voteCount }
        let newIndex = sortedQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId })!
        if newIndex != index {
            self.tableView.moveRow(at: IndexPath(item: index, section: 0), to: IndexPath(item: newIndex, section: 0))
            self.queue = sortedQueue
        }
        //        setting for mini Player
        
        currentSong = changedTrack
//        var currentSongID: String = currentSong?.trackId as! String
//        
//        SPTAudioStreamingController.sharedInstance().queueSpotifyURI("spotify:track:\(currentSongID)", callback: { (error) in
//            if error != nil{
//                print("Queue URI")
//            }
//        })
        miniPlayer?.setting(song: currentSong)
    }
    
    
    func onChildRemoved(changedTrack: TrackModel) {
        let index = getIndex(of: changedTrack)
        self.queue.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: .left)
    }
    
    //Helper function finding a changed Track in the existing queue
    func getIndex(of findTrack: TrackModel) -> Int {
        return self.queue.index(where: { (track) -> Bool in track.trackId == findTrack.trackId })!
    }
    
    
    @objc func search(){
        self.performSegue(withIdentifier: "showSearch", sender: self)
    }
    
    func freeObservers(){
        ref.removeAllObservers()
        self.ref = Database.database().reference()
    }

  override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
/*
 15.06.2018 - Chris
 To expand the UIPlayer/MaxiSongCardViewController
 
 */

extension PartyPlaylistViewController: MiniPlayerDelegate{
    func expandSong(song: TrackModel) {
       
        guard let expandedTrackCard = UIStoryboard(name: "UIPlayer", bundle: nil).instantiateViewController(withIdentifier: "ExpandedTrackViewController")
            as? ExpandedTrackViewController else {
                assertionFailure("No view controller ID ExpandedTrackViewController in this storyboard found")
                return
        }
        print("func call expandSong + \(currentSong!.songName)")
        expandedTrackCard.backingPic = view.makeFullScreenshot()
        expandedTrackCard.currentSong = song
        expandedTrackCard.isAdmin = isAdmin
        print("func call expandSong EXPANDEDTRACK")
        expandedTrackCard.sourceView = miniPlayer
        present(expandedTrackCard, animated: false)

    }
}
/*
                ^^              ^^
                ||              ||
            Helper just for extension "extension TrackPlayControlViewController: MiniPlayerDelegate"
 */
extension UIView  {
    /*
     Func screenshot without navigation bar
     */
//    func makeScreenshot() -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(bounds.size, true, 0.0)
//        drawHierarchy(in: bounds, afterScreenUpdates: true)
//        let screen = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        print("func call makeScreenshot")
//        return screen
//
//    }
    /*
     func screenshot with navigation bar / toolbar
     
     */
    func makeFullScreenshot() -> UIImage? {
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
//        drawHierarchy(in: bounds, afterScreenUpdates: true)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screen = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        print("func call makeScreenshot")
        return screen

    }
}

/*
 Data Source
 
 */

extension PartyPlaylistViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = queue[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackWithImage", for: indexPath) as! TrackCell
       

        
        
        cell.setup(from: track)
        cell.partyRef = self.ref
        return cell
    }
}

/*
 ViewDelegate
 
 */

extension PartyPlaylistViewController: UITableViewDelegate{
    
    //Set Custom Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 64.0;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let track = self.queue[indexPath.item]
        if !isAdmin{
            return UISwipeActionsConfiguration(actions: [])
        }
        let modifyAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            let alert = UIAlertController(title: "Are you sure you want to remove \(track.songName!)?", message: "This track had \(String(track.voteCount)) votes.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.ref.child("/queue/\(track.trackId as String)").removeValue()
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
            
            if track.liked{
                //Unlike
                self.ref.child("/queue/\(track.trackId as String)/votes").child(self.userID!).removeValue()
            } else {
                //Like
                self.ref.child("/queue/\(track.trackId as String)/votes").child(self.userID!).setValue(true)
            }
            success(true)
        })
        voteAction.image = UIImage(named: track.liked ? "favorite" : "favoriteOutline")
        voteAction.backgroundColor = UIColor(named: "Green")
        return UISwipeActionsConfiguration(actions: [voteAction])
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "The Show must go on! Keep adding Tracks."
        label.textAlignment = .center
        label.textColor = .white
        return label
    }
}
