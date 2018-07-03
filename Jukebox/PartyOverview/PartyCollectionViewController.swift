//
//  PartyCollectionViewController.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
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
    var selectedParty:String = ""
    var selectedPartyInfo:NSDictionary = [:]
    
    var cellMenuPartyId: String!
    var cellMenuPartyName: String!
    var cellMenuPartyHost: String!
    
    var cellPartyInfo: NSDictionary = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = Database.database().reference()

        getParties()
        setupLongPressGestureRecognizer()
    }

    func getParties() -> Void {

        let userID = Auth.auth().currentUser?.uid
        if userID == nil {
            return
        }
        self.hostParties = []
        self.guestParties = []
        ref.child("users/\(userID!)/parties").observe(.value) { (snapshot) in
            let parties = snapshot.value as? NSDictionary
            parties?.forEach({ (arg: (key: Any, value: Any)) in
                let (key, value) = arg
                self.ref.child("parties/\(key)").observeSingleEvent(of: .value, with: { (snapshot) in
                    switch value as! String{
                    case "host":
                        self.hostParties.append((snapshot.value as? NSDictionary)!)
                        self.hostPartyIds.append(key as! String)
                    default:
                        self.guestParties.append((snapshot.value as? NSDictionary)!)
                        self.guestPartyIds.append(key as! String)
                    }
                    self.collectionView?.reloadData()
                }) {(error) in print(error.localizedDescription)}
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
    
    func shapeImage(incImage: UIImage){
        let customImgView = CustomPartyImage()
        customImgView.image = incImage
        customImgView.frame = CGRect(x: 0, y: 0, width: 250, height: 250)
        
        self.view.addSubview(customImgView)
    }

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
            cell.PartyName.text = party.object(forKey: "ID") as! String
            cell.Label.text = party.object(forKey: "Name") as! String
            cell.PartyID = party.object(forKey: "ID") as! String
            cell.PartyHost = party.object(forKey: "Host") as! String
            cell.setCellShadow()
        }
        return cell
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
}

extension PartyCollectionViewController: UIGestureRecognizerDelegate{
    
    func setupLongPressGestureRecognizer(){
        let lpgr = UILongPressGestureRecognizer (target: self, action: #selector(handleLongPress(_:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        self.collectionView?.addGestureRecognizer(lpgr)
        self.collectionView?.isUserInteractionEnabled = true

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.destination is PartyMenuViewController){
            let vc = segue.destination as? PartyMenuViewController
            vc?.partyID = self.cellMenuPartyId
            vc?.partyName = self.cellMenuPartyName
            vc?.partyHost = self.cellMenuPartyHost
        }
    }
    
    @IBAction func handleLongPress(_ sender: UILongPressGestureRecognizer){
        let point = sender.location(in: collectionView)
        if let indexPath = collectionView?.indexPathForItem(at: point) {
            let cell = collectionView?.cellForItem(at: indexPath) as! PartyCollectionViewCell
            self.cellMenuPartyId = cell.PartyID
            self.cellMenuPartyName = cell.Label.text
            self.cellMenuPartyHost = cell.PartyHost
            
            performSegue(withIdentifier: "PartyMenu", sender: sender)
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
}
