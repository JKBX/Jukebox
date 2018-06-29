//
//  EditCardViewController.swift
//  Jukebox
//
//  Created by Philipp on 21.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import Kingfisher

class EditCardViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var delegate: CardDelegate?
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var profilePicture: UIImageView!
    var didChangeImage: Bool = false
    
    func update(_ user: User) {
        self.displayName.text = user.displayName
        if let image = user.photoURL {
            self.profilePicture.kf.setImage(with: image)
        } else { self.profilePicture.image = UIImage(named: "ProfilePictureDefault") }
        self.didChangeImage = false
        self.displayName.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func changeImage(_ sender: Any?) {
        imagePicker.delegate = self
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let finalImage = resizeImage(image: chosenImage)
        self.profilePicture.image = finalImage
        self.didChangeImage = true
        dismiss(animated: true, completion: nil)
    }
    
    func resizeImage(image: UIImage) -> UIImage? {
        let newSize = image.size.width > image.size.height ? image.size.height : image.size.width
        let size = CGSize(width: newSize, height: newSize)
        let origin = CGPoint(x: (image.size.width - size.width) / 2, y: (image.size.height - size.height) / 2)
        let cropRect = CGRect(origin: origin, size: size)
        guard let cropping = image.cgImage!.cropping(to: cropRect) else {print("Crop failed"); return nil}
        let squaredImage =  UIImage(cgImage: cropping, scale: 0, orientation: image.imageOrientation)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 256, height: 256), false, 1.0)
        squaredImage.draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 256, height: 256)))
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {print("Crop failed"); return nil}
        UIGraphicsEndImageContext()
        return newImage
    }
    
    @IBAction func update(_ sender: Any) {
        uploadProfilePicture { (imageUrl) in
            guard let update = Auth.auth().currentUser?.createProfileChangeRequest() else {print("Failed to Update Profile"); return }
            update.displayName = self.displayName.text
            if let url = imageUrl { update.photoURL = url }
            update.commitChanges(completion: { (error) in
                if let error = error {print(error); return}
                NotificationCenter.default.post(name: NSNotification.Name.loading, object:(false, "", self))
                self.delegate?.editing(false)
            })
        }
    }
    
    //PartyPicStorage
    func uploadProfilePicture(completion: @escaping (_ pictureURL: URL?)->Void) -> Void {
        // Get a reference to the storage service using the default Firebase App
        if !didChangeImage {completion(nil)}
        NotificationCenter.default.post(name: NSNotification.Name.loading, object:(true, "Updating Profile...", self))
        let storage = Storage.storage()
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let picture:Data = UIImageJPEGRepresentation(profilePicture.image!, 1)! as Data
        // Create a storage reference from our storage service
        let pictureRef = storage.reference().child("/profileImages/\((Auth.auth().currentUser?.uid)!)/picture.jpg")
        _ = pictureRef.putData(picture, metadata: metadata) { (metadata, error) in
            //guard let metadata = metadata else { completion(""); return }
            if let error = error {print(error); return}
            pictureRef.downloadURL(completion: { (url, error) in
                if let error = error {print(error); return}
                completion(url!)
            })
        }
    }
}
