//
//  SearchViewController.swift
//  Jukebox
//
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import Spartan

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    public static var authorizationToken: String?
    public static var loggingEnabled: Bool = true

    var ref: DatabaseReference! = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    var isAdmin: Bool = false
    var foundTracks: [TrackModel] = []
    var existingTracks: [TrackModel] = []

    var textSearchedFor: String = ""
    var sectionOneHeader: String = "Found in Playlist:"
    var sectionTwoHeader: String = "SPOTIFY Search Results: "

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        searchBar.backgroundColor = UIColor(named: "SolidGrey800")
        
        tableView.allowsSelection = false
        NotificationCenter.default.addObserver(forName: NSNotification.Name.isEditing, object: nil, queue: nil) { (note) in
           self.view.endEditing(true)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        searchBar.becomeFirstResponder()
        searchBar.showsCancelButton = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func searchTrackWithSpartanCall(track: String){
        Spartan.authorizationToken = SPTAuth.defaultInstance().session.accessToken
        foundTracks = []
        existingTracks = []
        _ = Spartan.search(query: track, type: .track, success: { (pagingObject: PagingObject<Track>) in
            for track in pagingObject.items{
                let searchResult = TrackModel.init(from: track)
                if let existing = searchResult.isIn(currentQueue){
                    self.existingTracks.append(existing)
                } else {
                    self.foundTracks.append(searchResult)
                }
            }
            self.tableView.reloadData()
        }, failure: { (error) in
            print(error)
        })
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return existingTracks.count
        } else{
            return foundTracks.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "existing", for: indexPath) as! TrackCell
            cell.setup(from: existingTracks[indexPath.row])
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "result", for: indexPath) as! SearchCell
            cell.setup(from: foundTracks[indexPath.row], delegate: self)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.backgroundColor = UIColor(named: "SolidGrey800")
        label.font = UIFont.boldSystemFont(ofSize: 15)
        if(foundTracks.count > 0){
            if(section == 0 && existingTracks.count > 0){
                label.text = sectionOneHeader
            }else if (section == 1) {
                label.text = sectionTwoHeader
            }
            return label
        }else{
            label.text = section == 0 ? "Keep searching Tracks!" : "(Cool Tracks!)"
            return label
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if(foundTracks.count == 0){return 1}
        return 2
    }
}

extension SearchViewController: UISearchBarDelegate {
    
//    if let existing = searchResult.isIn(currentQueue){
//        self.foundTracks = self.foundTracks.filter { $0.trackId == existing.trackId}
//        self.existingTracks.append(existing)
//    } else {
//      self.existingTracks = self.existingTracks.filter { $0.trackId == searchResult.trackId}
//      self.foundTracks.append(searchResult)
//    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            tableView.reloadData()
            searchBar.becomeFirstResponder()
        } else {
            searchTrackWithSpartanCall(track: searchBar.text!)
            tableView.reloadData()
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension SearchViewController: SearchCellDelegate{
    func showSuccess() {
        performSegue(withIdentifier: "404", sender: self)
    }
}

extension SearchViewController: QueueDelegate {
    func childAdded(_ track: TrackModel) {
        if let existing = track.isIn(foundTracks){
            ref.child("/parties/\(currentParty)/queue/\(track.trackId)").observeSingleEvent(of: .value, with: { (snapshot) in
                existing.voteCount = snapshot.childSnapshot(forPath: "votes").childrenCount + 1
                })
            self.existingTracks.append(existing)
            self.foundTracks = self.foundTracks.filter { $0.trackId != existing.trackId}
            tableView.reloadData()
        }
    }
    
    func childRemoved(_ track: TrackModel) {
        if let existing = track.isIn(existingTracks){
            self.foundTracks.append(existing)
//            self.existingTracks = self.existingTracks.filter { $0.trackId == existing.trackId}
            tableView.reloadData()
        }
    }
}
