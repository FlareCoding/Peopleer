//
//  EventDataManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/25/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//


class EventDataManager {
    
    static var event_locations = [
        ["type": "event", "title": "Peopleer Headquarters", "latitude": 40.711017, "longitude": -74.016937],
        ["type": "event", "title": "Test Event 1", "latitude": 40.701983, "longitude": -74.014356],
        ["type": "event", "title": "Test Event 2", "latitude": 40.709313, "longitude": -74.003489],
        ["type": "event", "title": "Test Event 3", "latitude": 40.692753, "longitude": -73.976649]
    ]
    
    static func RefreshEventData() {
        print("Refreshing event data")
    }
}
