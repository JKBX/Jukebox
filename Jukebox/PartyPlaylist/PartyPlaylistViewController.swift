//
//  PartyPlaylistViewController.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.

import UIKit
import FirebaseDatabase
import FirebaseAuth

class PartyPlaylistViewController: UIViewController{ //PlayerDelegate

    //MARK: Vars

    @IBOutlet weak var tableView: UITableView!
    var ref: DatabaseReference! = Database.database().reference()
    var miniPlayer: MiniPlayerViewController?
    let userID = Auth.auth().currentUser?.uid

    var addObserver: UInt?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let button = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.search, target: self, action: #selector(search))
        navigationItem.rightBarButtonItem = button
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Only set if coming from Party Overview
        if self.isMovingToParentViewController {
            setupObservers()
        }
    }

    //TODO ??
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? MiniPlayerViewController {

            miniPlayer = destination
            miniPlayer?.delegate = self

        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //Only Reset if moving to Party Overview
        if self.isMovingFromParentViewController {
            freeObservers()
            self.tableView.reloadData()
            //Stop Playback
            /*if (currentTrack?.isPlaying)! && currentAdmin {
                NotificationCenter.default.post(name: NSNotification.Name.Spotify.toggle, object: nil)
            }
            NotificationCenter.default.post(name: NSNotification.Name.Spotify.stopBroadcast, object: nil)*/
        }
    }


    //MARK: Observer-Methods

    func setupObservers() {
        self.ref = Database.database().reference().child("/parties/\(currentParty)")

        ref.child("/queue").observe(.childChanged, with: { (snapshot) in self.onChildChanged(TrackModel(from: snapshot))})
        addObserver = ref.child("/queue").observe(.childAdded, with: { (snapshot) in self.onChildAdded(TrackModel(from: snapshot))})
        ref.child("/queue").observe(.childRemoved, with: { (snapshot) in self.onChildRemoved(TrackModel(from: snapshot))})
        ref.child("/currentlyPlaying").observe(.value, with: { (snapshot) in self.onCurrentTrackChanged(snapshot)})
    }

    func onChildAdded(_ changedTrack: TrackModel) {
        currentQueue.append(changedTrack)
        currentQueue = currentQueue.sorted() { $0.voteCount > $1.voteCount }
        let index = getIndex(of: changedTrack)
        self.tableView.insertRows(at: [IndexPath(item: index, section: 0)], with: .automatic)

        self.tableView.reloadData()

    }

    func onChildChanged(_ changedTrack: TrackModel) {
        let index = getIndex(of: changedTrack)
        currentQueue[index] = changedTrack
        self.tableView.reloadRows(at: [IndexPath(item: index, section: 0)], with: .automatic)

        let sortedQueue = currentQueue.sorted() { $0.voteCount > $1.voteCount }
        let newIndex = sortedQueue.index(where: { (track) -> Bool in track.trackId == changedTrack.trackId })!

        if newIndex != index {
            self.tableView.moveRow(at: IndexPath(item: index, section: 0), to: IndexPath(item: newIndex, section: 0))
            currentQueue = sortedQueue
        }
    }


    func onChildRemoved(_ changedTrack: TrackModel) {
        let index = getIndex(of: changedTrack)
        currentQueue.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(item: index, section: 0)], with: UITableViewRowAnimation.left)
        self.tableView.reloadData()

    }


    func onCurrentTrackChanged(_ snapshot: DataSnapshot) {
        let needsCheck = currentTrack == nil
        currentTrack = snapshot.exists() ? TrackModel(from: snapshot) : nil
        if needsCheck && currentTrack != nil { self.ref.child("/currentlyPlaying/isPlaying").setValue(false) }
        NotificationCenter.default.post(name: NSNotification.Name.Player.trackChanged, object: nil)
        miniPlayer?.setting()
        miniPlayer?.update()
    }

    //Helper function finding a changed Track in the existing queue
    func getIndex(of findTrack: TrackModel) -> Int {
        //TODO Thread 1: Fatal error: Unexpectedly found nil while unwrapping an Optional value
        if currentQueue.count == 0 { return -1}
        return currentQueue.index(where: { (track) -> Bool in track.trackId == findTrack.trackId })!
    }


    @objc func search(){
        self.performSegue(withIdentifier: "showSearch", sender: self)
    }

    func freeObservers(){
        ref.child("/queue").removeAllObservers()
        ref.child("/currentlyPlaying").removeAllObservers()
        currentParty = ""
        currentQueue = []
        currentTrack = nil
        currentAdmin = false
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

        let track = currentQueue[indexPath.item]

        let voteAction = UIContextualAction(style: .normal, title:  "Update", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in

            success(true)
            if track.liked{
                //Unlike
                self.ref.child("/parties/\(currentParty)/queue/\(track.trackId as String)/votes").child(self.userID!).removeValue()
            } else {
                //Like
                self.ref.child("/parties/\(currentParty)/queue/\(track.trackId as String)/votes").child(self.userID!).setValue(true)
            }
        })
        voteAction.image = UIImage(named: track.liked ? "favorite" : "favoriteOutline")
        voteAction.backgroundColor = UIColor(named: "SolidBlue400")
        return UISwipeActionsConfiguration(actions: [voteAction])
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.font.withSize(8)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center

        if(currentQueue.count == 0){
            label.text = "Add Tracks! There is no song left!"
            label.textColor = .red
            return label}

        if(currentQueue.count <= 5 && currentQueue.count > 0){

            label.textColor = .white
            let myString:String = "Just \(currentQueue.count) songs left. Keep adding Tracks." as String
            let myMutableString = NSMutableAttributedString(string: myString)
            myMutableString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.red, range: NSRange(location:5,length:1))
            label.attributedText = myMutableString
            return label }

        else {
            label.isHidden = true
            return label
        }
        }
    }
