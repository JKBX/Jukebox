//
//  GlobalVariables.swift
//  Jukebox
//
//  Created by Philipp on 23.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation
import FirebaseDatabase

//var currentParty: String?
var currentTrack: TrackModel?
var currentQueue: [TrackModel] = []
var currentAdmin: Bool = false
var isBroadcasting: Bool = false
var currentTrackPosition: TimeInterval = 0

var currentParty:String = "" {
    willSet{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.streamingDelegate.willUpdate()
    }
    didSet {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.streamingDelegate.update()
    }
}
