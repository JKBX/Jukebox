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

class SearchViewController: UIViewController {
    
//    SPTAuth.defaultInstance.session.accessToken

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    public static var authorizationToken: String?
    public static var loggingEnabled: Bool = true
    
    var ref: DatabaseReference! = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    var isAdmin: Bool = false
    var partyID: String = ""
    
    var isSearching = false
    var foundTracks: [Track] = []
    var textSearchedFor: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getTrackFromSpartanCall(track: String){
//        _ = Spartan.getTrack(id: track, market: .us, success: { (track) in
//        // Do something with the track
//        }, failure: { (error) in
//        print(error)
//        })
    }
}

//extension SearchViewController: UITableViewDelegate{
//    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) -> CGFloat{
//        return 64.0
//    }
//}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return foundTracks.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let track = foundTracks[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackWithImage", for: indexPath) as! TrackCell
        cell.setup(from: track)
        cell.partyRef = self.ref.child("/parties/\(self.partyID)")
        return cell
    }
}

extension SearchViewController: UISearchBarDelegate {
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        <#code#>
//    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearching = false
            view.endEditing(true)
            tableView.reloadData()
        } else {
            isSearching = true
            getTrackFromSpartanCall(track: searchBar.text!)
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if isSearching {
            isSearching = false
        }
    }
}
