//
//  EventDataManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/25/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation
import UIKit

struct Event {
    var type        : String
    var title       : String
    var latitude    : Double
    var longitude   : Double
}

class EventDataManager {
    
    var events: [Event] = []
    //[
        //["type": "event", "title": "Peopleer Headquarters", "latitude": 40.711017, "longitude": -74.016937],
        //["type": "event", "title": "Test Event 1", "latitude": 40.701983, "longitude": -74.014356],
        //["type": "event", "title": "Test Event 2", "latitude": 40.709313, "longitude": -74.003489],
        //["type": "event", "title": "Test Event 3", "latitude": 40.692753, "longitude": -73.976649]
    //]
    
    private let TARGET_URL = "http://158.222.244.80:8000/events.json";
    
    func RefreshEventData(view: UIViewController? = nil, completionHandler: @escaping (_ events: [Event]) -> Void) {
        self.events = [] // removing all existing events
        
        NetworkManager.shared.getRequest(url: TARGET_URL) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    if view != nil {
                        UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured when conneting to server")
                    }
                    completionHandler(self.events)
                    return
                }
                
                guard data != nil else {
                    if view != nil {
                        UIUtils.showAlert(view: view!, title: "Data Error", message: "No data was recieved from the server")
                    }
                    completionHandler(self.events)
                    return
                }
                
                guard let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [String: Any] else {
                    if view != nil {
                        UIUtils.showAlert(view: view!, title: "JSON Error", message: "Data recieved was corrupt")
                    }
                    completionHandler(self.events)
                    return
                }
                
                let events = json["Events"] as! [[String : Any]]
                print("EVENT COUNT: \(String(describing: events.count))")
                
                for event in events {
                    self.RegisterNewEvent(event: event)
                }
                
                completionHandler(self.events)
            }
        }
    }
    
    private func RegisterNewEvent(event: [String : Any]) {
        let evt = Event(type: event["type"] as! String,
                        title: event["title"] as! String,
                        latitude: event["latitude"] as! Double,
                        longitude: event["longitude"] as! Double)
        events.append(evt)
    }
    
    static let shared = EventDataManager()
}
