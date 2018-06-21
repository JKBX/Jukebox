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
    
    @IBAction func create(_ sender: Any) {
        
    }
    
    @IBOutlet var addName: UITextField!
    @IBOutlet var addDate: UITextField!
    
    private var datePicker: UIDatePicker?
    
    @IBOutlet var addPlaylist: UITextField!
    @IBOutlet var addImage: UIButton!
    @IBOutlet var loadPicture: UIImageView!

    @IBOutlet var create: UIButton!
    @IBAction func createClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    let imagePicker = UIImagePickerController()
    
    var playlists: [SPTPartialPlaylist] = []
    var pickerDataSource = ["White", "Red", "Green", "Blue"]
    let picker:UIPickerView = UIPickerView()

    override func viewDidLoad(){
        super.viewDidLoad()
        
        //addPicture
        loadPicture.layer.borderWidth = 1
        loadPicture.layer.masksToBounds = false
        loadPicture.layer.cornerRadius = loadPicture.frame.height/2
        loadPicture.clipsToBounds = true
        
        //addDate
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        addDate.inputView = datePicker 
       
        
        let toolBar = UIToolbar().ToolbarPiker(mySelect: #selector(CreatePartyViewController.dismissPicker))
        addDate.inputAccessoryView = toolBar
        
    
        
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
    
    
    func datePickerValueChanged(sender:UIDatePicker){
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
        //Get date & write to input field
        
    }
    
    //addImage
    @IBAction func addImagePressed(_ sender: Any) {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
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

//datePicker
extension UIToolbar {
    
    func ToolbarPiker(mySelect : Selector) -> UIToolbar {
        
        let toolBar = UIToolbar()
        
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: nil)
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([ spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
}
