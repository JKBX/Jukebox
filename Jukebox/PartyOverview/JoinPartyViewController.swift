//
//  JoinPartyViewController.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Philipp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth


class JoinPartyViewController: UIViewController, UITextFieldDelegate {

 
    @IBOutlet var IDTextField: UITextField!
    @IBOutlet weak var userMobileNoTextFiled: UITextField!
    
        
    override func viewDidLoad() {
            super.viewDidLoad()
            IDTextField.delegate = self
    }
 
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if IDTextField.isFirstResponder == true {
           IDTextField.placeholder = ""
        }
    }
 
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 6
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }

    @IBAction func done(_ sender: Any) {
        let enteredID = IDTextField.text!
        let userId:String = (Auth.auth().currentUser?.uid)!
        let ref = Database.database().reference()
     
        ref.child("/parties").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children{
               let party = PartyModel(from:child as! DataSnapshot)
               if party.id == enteredID{
                  let partyKey = (child as! DataSnapshot).key
                  ref.child("users/\(userId)/parties/\(partyKey)").setValue("guest")
                  self.dismiss(animated: true, completion: nil)
               }
            }
        })
        self.dismiss(animated: true, completion: nil)
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
