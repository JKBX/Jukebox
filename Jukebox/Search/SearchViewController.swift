//
//  SearchViewController.swift
//  Jukebox
//
//  Created by Philipp on 11.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import Spartan

struct sPTFTrackModel {
    var name: String
    var artists: String
    var id: String
    var imageUrl: String
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    public static var authorizationToken: String?
    public static var loggingEnabled: Bool = true
    
    var ref: DatabaseReference! = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    var isAdmin: Bool = false
    var isSearching = false
    var partyID: String = ""
    var foundTracks: [TrackModel] = []
    var queue: [TrackModel] = []
    var textSearchedFor: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
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
        //        TODO: Abort request on continue editing
        _ = Spartan.search(query: track, type: .track, success: { (pagingObject: PagingObject<Track>) in
            for track in pagingObject.items{
                let searchResult = TrackModel.init(from: track)
                if guard let existingTrack = searchResult.isIn(currentQueue)
                existingTracks.append(existingTrack)
                //Append related track to upper section
        
                    else {
                    foundTracks.append(searchResult)
                }
                //self.foundTracks.append(TrackModel.init(from: track))
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
            return queue.count
        } else{
            return foundTracks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchTableTrack = indexPath.section == 0 ? foundTracks[indexPath.item] : queue[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackWithImage", for: indexPath) as! SearchCell
        cell.setup(from: searchTableTrack)
        cell.partyRef = self.ref.child("/parties/\(self.partyID)")
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Header"
        label.backgroundColor = UIColor.lightGray
        return label
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
            searchBar.becomeFirstResponder()
        } else {
            isSearching = true
            searchTrackWithSpartanCall(track: searchBar.text!)
            tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if isSearching {
            isSearching = false
        }
    }
}
