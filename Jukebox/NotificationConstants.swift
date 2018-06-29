//
//  NotificationConstants.swift
//  test
//
//  Created by Philipp on 25.04.18.
//  Copyright © 2018 Philipp. All rights reserved.
//

extension Notification.Name {
    struct Spotify {
        static let loggedIn = Notification.Name("loggedIn")
        static let toggle = Notification.Name("toggle")
        static let nextSong = Notification.Name("SptNext")
        static let prevSong = Notification.Name("SptRestart")
        static let startBroadcast = Notification.Name("SptStartBroadcast")
        static let stopBroadcast = Notification.Name("SptStopBroadcast")

    }
    
    struct Player {
        
        static let trackChanged = Notification.Name("player")
        
    }
    
}
