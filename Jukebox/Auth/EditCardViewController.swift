//
//  EditCardViewController.swift
//  Jukebox
//
//  Created by Philipp on 21.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth
import Kingfisher

class EditCardViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
/*class EditCardViewController: UIViewController, UIImagePickerControllerDelegate {*/
    var delegate: CardDelegate?

    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imagePicker.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(tapGestureRecognizer)
        profilePicture.layer.masksToBounds = true
        profilePicture.layer.cornerRadius = 64.0
        
        Auth.auth().addIDTokenDidChangeListener { (auth, _) in
            self.displayName.text = auth.currentUser?.displayName
            self.profilePicture.kf.setImage(with: auth.currentUser?.photoURL, options: [.processor(CenteredSquareProcessor())])
            self.profilePicture.layer.cornerRadius = self.profilePicture.bounds.height / 2
        }
        
       
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        //TODO add icons to actions
        let alertController = UIAlertController(title: nil, message: "Edit your image.", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in }
        alertController.addAction(cancelAction)
        
        //Open camera roll to load new Picture
        let replaceAction = UIAlertAction(title: "Upload from Camera Roll", style: .default) { action in
            self.imagePicker.allowsEditing = false
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil) }
        alertController.addAction(replaceAction)
        
        //Replace Image with Default user Picture
        let removeAction = UIAlertAction(title: "Remove", style: .default) { action in
            let defaultPicture = UIImage.init(named: "ProfilePictureDefault")
            self.profilePicture.image = defaultPicture }
        alertController.addAction(removeAction)
        
        self.present(alertController, animated: true) { }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.profilePicture.image = chosenImage
        //dismiss(animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func finishEditing(_ sender: Any) {
        var update = Auth.auth().currentUser?.createProfileChangeRequest()
        update?.displayName = displayName.text
        update?.commitChanges(completion: { (e) in
            if e != nil{
                print("Failed to update")
                return
            }
            print("Updated")
        })
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

protocol CardDelegate {
    func editing(_ active: Bool)
}
