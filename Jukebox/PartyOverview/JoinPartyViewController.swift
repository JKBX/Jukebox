//
//  JoinPartyViewController.swift
//  Jukebox
//
//  Created by Philipp on 09.05.18.
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
            IDTextField.delegate = self                  //set delegate
        }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                       replacementString string: String) -> Bool
        {
            let maxLength = 6
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }

    @IBAction func done(_ sender: Any) {
     let enteredID = IDTextField.text!
     let userId:String = (Auth.auth().currentUser?.uid)!
     let ref = Database.database().reference()
     
     ref.child("/parties").observeSingleEvent(of: .value, with: { (snapshot) in
      //print(snapshot)
     for child in snapshot.children{
       let party = PartyModel(from:child as! DataSnapshot)
       print(party.id)
       //print((party.childSnapshot(forPath: "ID").value) as! Int)
       if party.id == enteredID{
        let partyKey = (child as! DataSnapshot).key
        ref.child("users/\(userId)/parties/\(partyKey)").setValue("guest")
        self.dismiss(animated: true, completion: nil)
        print("Found party at \((child as! DataSnapshot).key)")
       }
      }
     })
        self.dismiss(animated: true, completion: nil)
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
