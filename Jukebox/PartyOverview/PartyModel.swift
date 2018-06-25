//
//  PartyModel.swift
//  Jukebox
//
//  Created by admin on 11.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation
import FirebaseDatabase


class Party {
    var date : Date
    var host : String
    var id : String
    var name : String
    var imagePath : String
    //var imageURL : NSURL
    
    init(from snapshot : DataSnapshot) {
        let value = snapshot.value as? NSDictionary
        
        self.date = (value?["Date"] as? Date)!
        self.name = value?["Name"] as? String ?? ""
        self.host = value?["Host"] as? String ?? ""
        self.id = value?["ID"] as? String ?? ""
        self.imagePath = value?["imagePath"] as? String ?? ""
        //self.imageURL = snapshot.childSnapshot(forPath: "imageUrl").value as! NSURL*/
    }
}
