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
    //var queue: [TrackModel] = []
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
        
        if segue.identifier == "showSearch" {
            let controller = segue.destination as! SearchViewController
            controller.partyID = self.partyID
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        currentQueue = []
        self.tableView.reloadData()
        self.ref = ref.child("/parties/\(self.partyID)")
        currentPartyId = self.partyID
        currentParty = ref.child("/parties/\(self.partyID)")
        setupObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        currentParty = Database.database().reference()
        currentTrack = nil
        freeObservers()
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
    
   
    
  
    
    //MARK: Observer-Methods
    
    func setupObservers() {
        ref.child("/queue").observe(.childChanged, with: { (snapshot) in self.onChildChanged(changedTrack: TrackModel(from: snapshot))})
        ref.child("/queue").observe(.childAdded, with: { (snapshot) in self.onChildAdded(changedTrack: TrackModel(from: snapshot))})
        ref.child("/queue").observe(.childRemoved, with: { (snapshot) in self.onChildRemoved(changedTrack: TrackModel(from: snapshot))})
        
        currentParty.observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot)
        }
        
        ref.child("currentlyPlaying").observe(.value, with: { (snapshot) in
            //self.onCurrentTrackChanged(currentTrack: TrackModel(from: snapshot))
            currentTrack = snapshot.exists() ? TrackModel(from: snapshot) : nil
            print(currentTrack)
        })
    }
    
    func onChildAdded(changedTrack: TrackModel) {
        //Todo test if only called on vote
        currentQueue.append(changedTrack)
        currentQueue = currentQueue.sorted() { $0.voteCount > $1.voteCount }
        let index = currentQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        
        self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: UITableViewRowAnimation.automatic)
    }
    
    func onChildChanged(changedTrack: TrackModel) {
        
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
        //Todo test if only called on vote
        let index = currentQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId }) as! Int
        currentQueue.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: UITableViewRowAnimation.left)
    }
    
    
    func onCurrentTrackChanged(currentTrack: TrackModel) {
        print(currentTrack)
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
        currentSong = currentTrack
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

/*
 ViewDelegate
 
 */

extension PartyPlaylistViewController: UITableViewDelegate{
    
    //Set Custom Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 64.0;
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        
        let track = currentQueue[indexPath.item]
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
        
        let track = currentQueue[indexPath.item]
        
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
