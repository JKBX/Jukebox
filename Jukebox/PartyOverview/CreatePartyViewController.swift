//
//  CreatePartyViewController.swift
//  Jukebox
//
//  Created by Philipp on 09.05.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class CreatePartyViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet var addName: UITextField!
    @IBOutlet var addDate: UITextField!
    
    @IBOutlet var addPlaylist: UITextField!
    @IBOutlet var addImage: UIButton!
    @IBOutlet var loadPicture: UIImageView!

    @IBOutlet var create: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var numbers: [Int] = []
    var playlists: [SPTPartialPlaylist] = []
    var pickerDataSource = ["White", "Red", "Green", "Blue"]
    let picker:UIPickerView = UIPickerView()

    override func viewDidLoad(){
        super.viewDidLoad()
        
        //datePicker
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(CreatePartyViewController.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
        addDate.inputView = datePicker
        
        //addPicture
        loadPicture.layer.borderWidth = 1
        loadPicture.layer.masksToBounds = false
        loadPicture.layer.cornerRadius = loadPicture.frame.height/2
        loadPicture.clipsToBounds = true
        
        //let picker = UIPickerView()
        //picker.translatesAutoresizingMaskIntoConstraints = false
        picker.dataSource = self
        picker.delegate = self
        //view.addSubview(self.picker) //TODO
        addPlaylist.inputView = picker
        
    /*
        picker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
   */     // Do any additional setup after loading the view.
        
        // Load Playlist Data For Fallback
        //TODO clean recursion 
        let user = SPTAuth.defaultInstance().session.canonicalUsername
        let accessToken = SPTAuth.defaultInstance().session.accessToken
        var callback:SPTRequestCallback = {(error, data) in
            if error != nil{ print(error); return }
            guard let playlists = data as? SPTPlaylistList else { print("Couldn't cast as SPTPlaylistList"); return }
            self.playlists = self.playlists + (playlists.items as? [SPTPartialPlaylist])!
            if playlists.hasNextPage {
                self.getNextPage(playlists: playlists)
            } else {
                print("Done loading Playlists")
                print(self.playlists)
                self.picker.reloadAllComponents()
            }
        }
        SPTPlaylistList.playlists(forUser: user, withAccessToken: accessToken, callback: callback)
    }
    //datePicker
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        addDate.text = formatter.string(from: sender.date)
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //addImage
    @IBAction func addImagePressed(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //imagePicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            loadPicture.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func getNextPage(playlists: SPTListPage) -> Void {
        // Load Playlist Data
        let accessToken = SPTAuth.defaultInstance().session.accessToken
        let callback:SPTRequestCallback = {(error, data) in
            if error != nil{ print(error); return }
            guard let playlists = data as? SPTListPage else { print("Couldn't cast as SPTListPage"); return }
            self.playlists = self.playlists + (playlists.items as? [SPTPartialPlaylist])!
            if playlists.hasNextPage {
                self.getNextPage(playlists: playlists)
            } else {
                print("Done loading Playlists")
                print(self.playlists)
                self.picker.reloadAllComponents()
            }
        }
        playlists.requestNextPage(withAccessToken: accessToken, callback: callback)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.playlists.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(self.playlists[row].name)
        return self.playlists[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        addPlaylist.text = playlists[row].name
    }
    
    //PartyId
    func generatePartyId(completion: @escaping (_ id: String)->Void) {
        let min: UInt32 = 000000
        let max: UInt32 = 999999
        var newId : String = ""
        Database.database().reference().child("parties").observeSingleEvent(of: .value) { (snapshot) in
            var ids:[String] = []
           
            for party in snapshot.children{
                if let party : DataSnapshot = party as? DataSnapshot {
                    ids.append((party.childSnapshot(forPath: "ID").value as? String)!)
                }
            }
            repeat { newId = "\((min + arc4random_uniform(max - min + 1)))" }
            while(ids.index(of: newId) != nil)
            completion(newId)
        }
    }
    
    //PartyPicStorage
    func uploadPartyPicture(for partyId: String, completion: @escaping (_ path: String)->Void) -> Void {
        // Get a reference to the storage service using the default Firebase App
        let storage = Storage.storage()
        let picture:Data = (UIImagePNGRepresentation(loadPicture.image!) as Data?)!
        
        // Create a storage reference from our storage service
        let pictureRef = storage.reference().child("/partyImages/\(partyId)/").child("party.png")
        
        let uploadTask = pictureRef.putData(picture, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else { return }
            completion(metadata.path!)
        }
    }

    
    @IBAction func createPressed(_ sender: UIButton) {
        let ref = Database.database().reference()
        let enteredName = addName.text!
        let enteredDate = addDate.text!
        let enteredPlaylist = addPlaylist.text!
        let hostId:String = (Auth.auth().currentUser?.uid)!
        generatePartyId { (partyId) in
            self.uploadPartyPicture(for: partyId, completion: { (imagePath) in
                let newParty: NSDictionary = [
                    "Date": enteredDate,
                    "Host": hostId,
                    "ID" : partyId,
                    "Name" : enteredName,
                    "imagePath" : imagePath,
                ]
                ref.child("/parties").childByAutoId().setValue(newParty, withCompletionBlock: { (_, _) in
                    self.dismiss(animated: true, completion: nil)
                })
            })
            
        }
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
