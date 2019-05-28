//
//  Event.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/26/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation

struct Event {
    var title       = "Title"
    var owner       = "None"
    var latitude    = 0.0
    var longitude   = 0.0
    var description = "Not Specified"
    var address     = "Not Specified"
    var maxParticipants     = 0
    var currentParticipants = 0
    var startTime   = Date()
    var endTime     = Date()
}
