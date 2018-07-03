//
//  NotificationConstants.swift
//  test
//
//  Created by Team Jukebox/Gruppe 7
//  Copyright © 2018 Philipp. All rights reserved.
//

extension Notification.Name {
    struct Spotify {
        static let loggedIn = Notification.Name("loggedIn")
        static let loggedOut = Notification.Name("loggedOut")
        static let toggle = Notification.Name("toggle")
        static let nextSong = Notification.Name("SptNext")
        static let prevSong = Notification.Name("SptRestart")
        static let broadcast = Notification.Name("spotifyToggleBroadcast")
        //static let startBroadcast = Notification.Name("SptStartBroadcast")
        //static let stopBroadcast = Notification.Name("SptStopBroadcast")

    }
    struct Player {
        static let broadcast = Notification.Name("broadcast")
        static let trackChanged = Notification.Name("player")
        static let lastSong = Notification.Name("lastSong")
        static let searchNewTrack = Notification.Name("searchNewTrack")
        
        //For player timing
        static let position = Notification.Name("songDuration")
        static let isPlay = Notification.Name("isPlay")




    }
    static let isEditing = Notification.Name("editingExit")
    static let loading = Notification.Name("loading")
}
