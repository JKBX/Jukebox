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
    var foundTracks: [TrackModel] = []
    var existingTracks: [TrackModel] = []

    var textSearchedFor: String = ""
    var sectionOneHeader: String = "In Queue"
    var sectionTwoHeader: String = "Spotify Results"

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
                if(searchResult.isIn(currentQueue) != nil){
                    self.existingTracks.append(searchResult)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "trackWithImage", for: indexPath) as! SearchCell
            cell.setup(from: existingTracks[indexPath.row])
            return cell

        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "trackWithImage", for: indexPath) as! SearchCell
            cell.setup(from: foundTracks[indexPath.row])
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        if(section == 0 ){
            label.text = sectionOneHeader
        }else {
            label.text = sectionTwoHeader
        }
        label.backgroundColor = UIColor.darkGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.white
        return label
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension SearchViewController: UISearchBarDelegate {

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
        searchBar.text = ""
    }
}
