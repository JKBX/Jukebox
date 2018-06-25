//
//  GlobalVariables.swift
//  Jukebox
//
//  Created by Philipp on 23.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation
import FirebaseDatabase

var currentParty: String?
var currentTrack: TrackModel?
var currentQueue: [TrackModel] = []
var currentAdmin: Bool = false
