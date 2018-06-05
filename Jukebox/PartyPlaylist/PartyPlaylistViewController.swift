//
//  PartyPlaylistViewController.swift
//  Jukebox
//
//  Created by Philipp on 22.05.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseDatabase

class PartyPlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Vars
    
    var ref: DatabaseReference! = Database.database().reference()
    var isAdmin: Bool = false
    var partyID: String = ""
    var queue: [NSDictionary] = []
    
    //MARK: TableViewMethods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queue.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "trackCell", for: indexPath) as! TrackCell
        cell.songTitleLabel.text = queue[indexPath.item].value(forKey: "Name") as? String
        cell.songArtistLabel.text = queue[indexPath.item].value(forKey: "Artist") as? String
        return cell
    }
    
    //MARK: LifeCycle
    var party:NSDictionary = [:]
    
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        let queueObserver = ref.child("/Paries/\(self.partyID)/Queue").observe(DataEventType.value, with: { (snapshot) in
            self.queue = snapshot.value as! [NSDictionary]
        })
        super.viewDidLoad()
        print(party)
        label.text = party.value(forKey: "Name") as! String
        // Do any additional setup after loading the view.
    }
    
    //MARK: Methods

    @IBAction func likeTrack(_sender: UIButton){
        ref.child("/Paries/\(self.partyID)/Queue/Track/Votes").observeSingleEvent(of: .value, with: { (snapshot) in
            //TODO: get userID!
            if snapshot.hasChild("userID"){
//                self.ref.removeValue("userID")
                print("unliked track")
            }else{
//                self.ref.child("/Paries/\(self.partyID)/Queue/Track/Votes").setValue("userID")
                print("liked track")
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
     
     // Configure the cell...
     
     return cell
     }
     */
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    

}
