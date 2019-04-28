//
//  EventDataManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/25/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation

struct Event {
    var type        : String
    var title       : String
    var latitude    : Double
    var longitude  : Double
}

class EventDataManager {
    
    static var events: [Event] = []
    //[
        //["type": "event", "title": "Peopleer Headquarters", "latitude": 40.711017, "longitude": -74.016937],
        //["type": "event", "title": "Test Event 1", "latitude": 40.701983, "longitude": -74.014356],
        //["type": "event", "title": "Test Event 2", "latitude": 40.709313, "longitude": -74.003489],
        //["type": "event", "title": "Test Event 3", "latitude": 40.692753, "longitude": -73.976649]
    //]
    
    private static let TARGET_URL = "http://192.168.0.11:8000/events.json";
    
    static func RefreshEventData() {
        /*
         let request = URLRequest(url: URL(string: TARGET_URL)!)
         let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
         if let data = data {
         do {
         let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
         let events = json["Events"] as! [[String : Any]]
         self.events = [] // resetting all events
         print("EVENT COUNT: \(String(describing: events.count))")
         for event in events {
         RegisterNewEvent(event: event)
         }
         } catch {
         print(error.localizedDescription)
         }
         }
         }
         task.resume()
         */
        
        guard let url = URL(string: TARGET_URL) else {
            print("Invalid URL")
            return
        }
        
        let session = URLSession.shared
        session.invalidateAndCancel()
        session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            if response != nil {
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                        let events = json["Events"] as! [[String : Any]]
                        self.events = [] // resetting all events
                        print("EVENT COUNT: \(String(describing: events.count))")
                        for event in events {
                            RegisterNewEvent(event: event)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            } else {
                print("Failed to connect with the server  | Error: \(String(describing: error))")
            }
        }.resume()
    }
    
    private static func RegisterNewEvent(event: [String : Any]) {
        let evt = Event(type: event["type"] as! String,
                        title: event["title"] as! String,
                        latitude: event["latitude"] as! Double,
                        longitude: event["longitude"] as! Double)
        events.append(evt)
    }
}
