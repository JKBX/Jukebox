 //
//  TrackSubscriber.swift
//  Jukebox
//
//  Created by Christian Reiner on 13.06.18.
//  Copyright © 2018 Jukebox. All rights reserved.
//

import Foundation

 protocol TrackSubscriber: class {
    var currentSong: TrackModel? {get set}
 }
