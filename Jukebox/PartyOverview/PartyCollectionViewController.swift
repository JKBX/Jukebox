//
//  PartyCollectionViewController.swift
//  Jukebox
//
//  Created by Philipp on 09.05.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"

class PartyCollectionViewController: UICollectionViewController {

    var ref: DatabaseReference!
    var hostParties:[NSDictionary] = []
    var hostPartyIds:[String] = []
    var guestParties:[NSDictionary] = []
    var guestPartyIds:[String] = []
    //var selectedParty:NSDictionary = [:]
    var selectedParty:String = ""
    var selectedPartyInfo:NSDictionary = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Ready")

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        self.ref = Database.database().reference()
        /*let sampleParty: NSDictionary = [
            "Name" : "Another Lit Party",
            "Host" : Auth.auth().currentUser?.uid,
            "Date" : "18.05.2018"
        ]
        self.ref.child("parties").childByAutoId().setValue(sampleParty)*/


        getParties()

        // Do any additional setup after loading the view.
        setupLongPressGestureRecognizer()
    }

    func getParties() -> Void {

        let userID = Auth.auth().currentUser?.uid
        if userID == nil {
            return
        }
        self.hostParties = []
        self.guestParties = []
        //ref.child("users/\(userID!)/parties").observeSingleEvent(of: .value, with: { (snapshot) in
        ref.child("users/\(userID!)/parties").observe(.value) { (snapshot) in
                // Get user value
            let parties = snapshot.value as? NSDictionary
            print("\(snapshot.value)")
            parties?.forEach({ (arg: (key: Any, value: Any)) in
                let (key, value) = arg
                self.ref.child("parties/\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    switch value as! String{
                    case "host":
                        self.hostParties.append((snapshot.value as? NSDictionary)!)
                        self.hostPartyIds.append(key as! String)
                    default:
                        //print("\(snapshot.value)")
                        self.guestParties.append((snapshot.value as? NSDictionary)!)
                        self.guestPartyIds.append(key as! String)
                    }
                    self.collectionView?.reloadData()
                }) {(error) in print(error.localizedDescription)}
            })
        }/*) {(error) in print(error.localizedDescription)}*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        print("2 section")
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        switch section {
        case 0:
            return self.hostParties.count
        default:
            return self.guestParties.count
        }
    }

    func getParty(for indexPath: IndexPath) -> (party: NSDictionary, id: String){
        switch indexPath.section {
        case 0:
            return (party: self.hostParties[indexPath.item], id: self.hostPartyIds[indexPath.item])
        default:
            return (party: self.guestParties[indexPath.item], id: self.guestPartyIds[indexPath.item])
        }
    }

// setzt die PartyBilder, leider gerade willkürlich und gleiche bilder werden mehrmals gesetzt

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PartyCollectionViewCell
        let (party, _) = getParty(for: indexPath)
        let imagePath = party.object(forKey: "imagePath") as! String
        if imagePath.contains("default") {
            print("From assets")
            cell.Image.image = UIImage(named: imagePath)
        } else {

            let imageReference = Storage.storage().reference(withPath: imagePath)

                        imageReference.downloadURL(completion: { (url, error) in
                            if (error == nil) {
                                if let downloadUrl = url {
                                    // Make you download string
                                    cell.Image.kf.indicatorType = .activity
                                    cell.Image.kf.setImage(with: downloadUrl, placeholder: UIImage(named: "AppIcon"))
                                }
                            } else {
                                imageReference.getData(maxSize: 1 * 512 * 512) { data, error in
                                    if let error = error {print(error)}
                                    else {
                                        cell.Image.image = UIImage(data: data!) }
                                }
                            }
                        })

            cell.Label.text = party.object(forKey: "Name") as! String
            cell.PartyID = party.object(forKey: "ID") as! String
        }
        return cell

        // ALT oben NEU mit Kingfisher


        //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
        //                                                      for: indexPath) as! PartyCollectionViewCell
        //        let (party, _) = getParty(for: indexPath)
        //        let imagePath = party.object(forKey: "imagePath") as! String
        //        if imagePath.contains("default") {
        //            print("From assets")
        //            cell.Image.image = UIImage(named: imagePath)
        //        } else {
        //
        //            let imageReference = Storage.storage().reference(withPath: imagePath)
        //            imageReference.getData(maxSize: 1 * 512 * 512) { data, error in
        //                if let error = error {print(error)}
        //                else {
        //                    cell.Image.image = UIImage(data: data!) }
        //            }
        //            cell.Label.text = party.object(forKey: "Name") as! String
        //        }
        //        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? SectionHeader{
            switch indexPath.section{
            case 0:
                sectionHeader.Label.text = "Parties you Host"
                sectionHeader.Button.addTarget(self, action: #selector(self.createParty), for: .touchUpInside)
            default:
                sectionHeader.Label.text = "Parties you Attend"
                sectionHeader.Button.addTarget(self, action: #selector(self.joinParty), for: .touchUpInside)
            }
            //sectionHeader.Label.text = "Section \(indexPath.section)"
            return sectionHeader
        }
        return UICollectionReusableView()
    }

    @objc func createParty() -> Void{
        self.performSegue(withIdentifier: "createParty", sender: self)
    }

    @objc func joinParty() -> Void{
        self.performSegue(withIdentifier: "joinParty", sender: self)
    }


    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    //TODO Long press to remove

    // Uncomment this method to specify if the specified item should be selected

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (self.selectedPartyInfo, self.selectedParty) = getParty(for: indexPath)
        self.performSegue(withIdentifier: "showParty", sender: self)
        currentAdmin = (self.selectedPartyInfo.value(forKey: "Host") as! String) == Auth.auth().currentUser?.uid
        currentParty = self.selectedParty
        self.selectedParty = ""
        
    }


    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    /*override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print(indexPath)
        self.performSegue(withIdentifier: "showParty", sender: self)

    }*/
}

extension PartyCollectionViewController: UIGestureRecognizerDelegate{
    
    func setupLongPressGestureRecognizer(){
        let lpgr = UILongPressGestureRecognizer (target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
        self.collectionView?.isUserInteractionEnabled = true

    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer){
        let point = sender.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point) {
            print(#function, indexPath)
            let cell = collectionView?.cellForItem(at: indexPath) as! PartyCollectionViewCell
            print(cell.PartyID)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point),
            let cell = collectionView?.cellForItem(at: indexPath) {
            return touch.location(in: cell).y > 50
        }
        return false
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        if segue.identifier == "PartyMenu" {
//            let next: PartyMenuViewController = segue.destination as! PartyMenuViewController
//            let indexPath1 = collectionView?.indexPath(for: sender as! PartyCollectionViewCell)
//            let cell = collectionView?.cellForItem(at: indexPath1!) as! PartyCollectionViewCell
//            let PMVC = PartyMenuViewController()
//            PMVC.partyID = cell.PartyID
//        }
//    }
//
//    @objc func showResetMenu(_ gestureRecognizer: UILongPressGestureRecognizer) {
//        if gestureRecognizer.state == .began {
//            self.becomeFirstResponder()
////            self.viewForReset = gestureRecognizer.view
//
//            // Configure the menu item to display
//            let menuItemTitle = NSLocalizedString("Reset", comment: "Reset menu item title")
//            let action = #selector(handleLongPress)
//            let resetMenuItem = UIMenuItem(title: menuItemTitle, action: action)
//
//            // Configure the shared menu controller
//            let menuController = UIMenuController.shared
//            menuController.menuItems = [resetMenuItem]
//
//            // Set the location of the menu in the view.
//            let location = gestureRecognizer.location(in: gestureRecognizer.view)
//            let menuLocation = CGRect(x: location.x, y: location.y, width: 0, height: 0)
//            menuController.setTargetRect(menuLocation, in: gestureRecognizer.view!)
//
//            // Show the menu.
//            menuController.setMenuVisible(true, animated: true)
//        }
//    }
    
}
