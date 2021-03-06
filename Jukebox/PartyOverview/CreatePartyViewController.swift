//
//  CreatePartyViewController.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

class CreatePartyViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate{

    @IBOutlet var addName: UITextField!
    @IBOutlet var addDate: UITextField!
    
    @IBOutlet weak var partyImage: UIImageView!
    @IBOutlet var addPlaylist: UITextField!
    
    let imagePicker = UIImagePickerController()
    
    var playlists: [SPTPartialPlaylist] = []
    let picker:UIPickerView = UIPickerView()

    override func viewDidLoad(){
        super.viewDidLoad()
        getActualDate()
        setupImagePicker()
        setupDatePicker()
        setupPlaylistPicker()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    
    @IBAction func done(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func generatePartyId(completion: @escaping (_ id: String)->Void) {
        let min: UInt32 = 000000, max: UInt32 = 999999
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
    
    func uploadPartyPicture(for partyId: String, completion: @escaping (_ path: String)->Void) -> Void {
        let storage = Storage.storage()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let picture: Data = UIImageJPEGRepresentation(partyImage.image!, 0.2)! as Data
        let pictureRef = storage.reference().child("/partyImages/\(partyId).jpg")
        _ = pictureRef.putData(picture, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else { completion(""); return }
            completion(metadata.path!)
        }
    }
    
    //Create
    @IBAction func createPressed(_ sender: UIButton) {
        print("create party")
        let enteredName = addName.text!
        let enteredDate = addDate.text!
        let playlistIdx = picker.selectedRow(inComponent: 0) - 1
        
        let ref = Database.database().reference()
        let hostId:String = (Auth.auth().currentUser?.uid)!
        
        if (enteredName.isEmpty || enteredDate.isEmpty){
            let alert = UIAlertController(title: "Not so fast!", message: "Add a Name and a Date to your Party.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok, cool!", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        generatePartyId { (partyId) in
            self.uploadPartyPicture(for: partyId, completion: { (imagePath) in
                let newParty: NSDictionary = [
                    "Date": enteredDate,
                    "Host": hostId,
                    "ID" : partyId,
                    "Name" : enteredName,
                    "imagePath" : imagePath,
                ]
                print("Name & Date added")
                ref.child("/parties/\(partyId)").setValue(newParty, withCompletionBlock: { (_, _) in
                    if playlistIdx != -1{
                        self.add(self.playlists[playlistIdx].playableUri, to: partyId) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        self.dismiss(animated: true, completion: nil)
                    }
                })
                ref.child("/users/\(hostId)/parties/\(partyId)").setValue("host")
            })
            
        }
        }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.blackTranslucent
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.white
        toolBar.sizeToFit()
        toolBar.backgroundColor = UIColor.black
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: mySelect)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}

//Image Picker Extension
extension CreatePartyViewController: UIImagePickerControllerDelegate{
    
    func setupImagePicker() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            partyImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

//Date Picker Extension
extension CreatePartyViewController{
    
    func setupDatePicker(){
        let datePicker = UIDatePicker()
        datePicker.tintColor = UIColor.lightText
        datePicker.backgroundColor = UIColor.darkGray
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(self.datePickerValueChanged(sender:)), for: .valueChanged)
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(self.dismissPicker))
        addDate.inputAccessoryView = toolBar
        addDate.inputView = datePicker
    }
    
    func getActualDate(){
        let formatterDate = DateFormatter()
        formatterDate.dateStyle = DateFormatter.Style.medium
        formatterDate.timeStyle = DateFormatter.Style.none
        let actualDate = formatterDate.string(from: Date())
        addDate.text = actualDate
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        addDate.text = formatter.string(from: sender.date)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
}

//Date & Playlist Picker Extension
extension CreatePartyViewController:  UIPickerViewDataSource, UIPickerViewDelegate{
    
    func setupPlaylistPicker() {
        picker.backgroundColor = UIColor.darkGray
        picker.dataSource = self
        picker.delegate = self
        self.loadPlaylists(nil)
        addPlaylist.inputView = picker
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(self.dismissPicker))
        addPlaylist.inputAccessoryView = toolBar
    }
    
    func loadPlaylists(_ page: SPTListPage?) -> Void {
        let user = SPTAuth.defaultInstance().session.canonicalUsername
        let accessToken = SPTAuth.defaultInstance().session.accessToken
        let callback:SPTRequestCallback = {(error, data) in
            if error != nil{ print(error); return }
            guard let page = data as? SPTListPage else { print("Couldn't cast as SPTListPage"); return }
            if let lst = page.items as? [SPTPartialPlaylist]{
                self.playlists = self.playlists + lst
            }
            if page.hasNextPage { self.loadPlaylists(page) }
            else { self.picker.reloadAllComponents() }
        }
        if let page = page {
            page.requestNextPage(withAccessToken: accessToken, callback: callback)
        } else {
            SPTPlaylistList.playlists(forUser: user, withAccessToken: accessToken, callback: callback)
        }
    }
    
    func add(_ playlistURI: URL!, to partyId: String!, with completion: @escaping ()->Void){
        let ref = Database.database().reference().child("parties/\(partyId!)/queue")
        let accessToken = SPTAuth.defaultInstance().session.accessToken
        SPTPlaylistSnapshot.playlist(withURI: playlistURI, accessToken: accessToken!) { (error, data) in
            if error != nil{ print(error); return }
            guard let snapshot = data as? SPTPlaylistSnapshot else { print("Couldn't cast as SPTListPage"); return }
            var queue: NSMutableDictionary = [:]
            if snapshot.firstTrackPage.items == nil {completion(); return}
            for item in snapshot.firstTrackPage.items{
                guard let track = item as? SPTPartialTrack else { print("Couldn't cast as SPTPartialTrack"); return }
                var artist = ""
                for item in track.artists {
                    guard let a = item as? SPTPartialArtist else { print("Couldn't cast as SPTPartialArtist"); return }
                    artist.append("\(a.name!), ")
                }
                artist.removeLast(2)
                let newTrack: NSDictionary = [
                    "songTitle": track.name,
                    "artist": artist,
                    "albumTitle": track.album.name,
                    "coverURL": track.album.largestCover.imageURL.absoluteString,
                    "duration": Int(track.duration * 1000)
                ]
                queue["\(track.identifier!)"] = newTrack
            }
            ref.setValue(queue, withCompletionBlock: { (error, _) in
                if error != nil {print(error)}
                completion()
            })
            
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.playlists.count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {return nil}
        return self.playlists[row - 1].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {addPlaylist.text = nil; return}
        addPlaylist.text = playlists[row - 1].name
    }
    
}
