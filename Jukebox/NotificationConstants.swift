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
        static let playSong = Notification.Name("SptPlay")
        static let pauseSong = Notification.Name("SptPause")
        static let nextSong = Notification.Name("SptNext")
    }
    
}
