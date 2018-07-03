//
//  GlobalVariables.swift
//  Jukebox
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation
import FirebaseDatabase


enum BroadcastState {
    case active
    case inactive
    case updating
}
//var currentParty: String?
var currentTrack: TrackModel?
var currentQueue: [TrackModel] = []
var currentAdmin: Bool = false
var broadcasting: BroadcastState = .inactive {didSet{NotificationCenter.default.post(name: NSNotification.Name.Player.broadcast, object: nil)}}
var currentTrackPosition: TimeInterval = 0
var triggerLastSong:Bool = true

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

