//
//  GlobalVariables.swift
//  Jukebox
//
//  Created by Philipp on 23.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation
import FirebaseDatabase

var currentParty: DatabaseReference! = Database.database().reference()
var currentTrack: TrackModel?
var currentQueue: [TrackModel] = []
var currentPartyId: String?
