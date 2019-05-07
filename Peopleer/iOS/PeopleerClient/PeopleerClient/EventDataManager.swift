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
    var title       = "Title"
    var latitude    = 0.0
    var longitude   = 0.0
}

class EventDataManager {
    
    static let shared = EventDataManager()
    
    var events: [Event] = []
    
    private struct EventServiceRequests {
        static let GetAllEvents         = "get_all_events"
        static let InsertEvent          = "insert_event"
        static let GetSpecificEvent     = "get_specific_event"
        static let DeleteEvent          = "delete_event"
        static let ModifyEvent          = "modify_event"
    }
    
    private let EVENTS_SERVICE_URL = "http://158.222.244.80:8000/peopleer_events_service.php"
    
    func RetrieveEvents(view: UIViewController? = nil, completionHandler: @escaping (_ events: [Event]) -> Void) {
        self.events = [] // removing all existing events
        
        var postMsg = "servreq=\(EventServiceRequests.GetAllEvents)"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: postMsg) { data, response, error in
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
                
                guard let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? [[String : Any]] else {
                    if view != nil {
                        UIUtils.showAlert(view: view!, title: "JSON Error", message: "Received data was corrupt")
                    }
                    completionHandler(self.events)
                    return
                }
                
                for event in json {
                    self.events.append(self.ParseEventData(event: event))
                }
                
                completionHandler(self.events)
            }
        }
    }
    
    private func ParseEventData(event: [String : Any]) -> Event {
        let evt = Event(title: event["title"] as! String,
                        latitude: (event["latitude"] as! NSString).doubleValue,
                        longitude: (event["longitude"] as! NSString).doubleValue)
        return evt
    }
    
    func CreateNewEvent(view: UIViewController? = nil, event: Event, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.InsertEvent)&event_title=\(event.title)&lat=\(event.latitude)&long=\(event.longitude)"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: postMsg) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if statusCode != 200 {
                        // error occured
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
                        }
                        completionHandler(false)
                        return
                    }
                    
                    guard data != nil else {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                        }
                        completionHandler(false)
                        return
                    }
                    
                    guard let server_response = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
                        [String : String] else {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                        }
                        completionHandler(false)
                        return
                    }
                    
                    if server_response["status"] == "error" {
                        if view != nil {
                            let err = server_response["error"]!
                            var errorMsg = "Error: \(String(describing: err))"
                            if err.contains("Duplicate entry") {
                                errorMsg = "Event with this name already exists"
                            }
                            
                            UIUtils.showAlert(view: view!, title: "Failed to Create Event", message: errorMsg)
                        }
                        completionHandler(false)
                        return
                    }
                    
                    completionHandler(true)
                }
            }
        }
    }
    
    func GetSpecificEvent(event_title: String, view: UIViewController? = nil, completionHandler: @escaping (_ event: Event?) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.GetSpecificEvent)&event_title=\(event_title)"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: postMsg) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    var result_evt: Event? = nil
                    let statusCode = HTTPResponse.statusCode
                    if statusCode != 200 {
                        // error occured
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
                        }
                        completionHandler(result_evt)
                        return
                    }
                    
                    guard data != nil else {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                        }
                        completionHandler(result_evt)
                        return
                    }
                    
                    guard let server_response = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
                        [[String : String]] else {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "JSON Error", message: "Received data was corrupt")
                            }
                            completionHandler(result_evt)
                            return
                    }
                    
                    if server_response.count < 1 {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Error", message: "Could not load event data")
                        }
                        completionHandler(result_evt)
                        return
                    }
                    
                    let event_data = server_response[0]
                    result_evt = self.ParseEventData(event: event_data)
                    
                    completionHandler(result_evt)
                }
            }
        }
    }
    
    func DeleteEvent(event_title: String, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.DeleteEvent)&event_title=\(event_title)"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: postMsg) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if statusCode != 200 {
                        // error occured
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
                        }
                        completionHandler(false)
                        return
                    }
                    
                    guard data != nil else {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                        }
                        completionHandler(false)
                        return
                    }
                    
                    guard let server_response = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
                        [String : String] else {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                            }
                            completionHandler(false)
                            return
                    }
                    
                    if server_response["status"] == "error" {
                        if view != nil {
                            let err = server_response["error"]!
                            let errorMsg = "Error: \(String(describing: err))"
                            UIUtils.showAlert(view: view!, title: "Failed to Create Event", message: errorMsg)
                        }
                        completionHandler(false)
                        return
                    }
                    
                    completionHandler(true)
                }
            }
        }
    }
    
    func ModifyEvent(event_title: String, view: UIViewController? = nil, event: Event, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.ModifyEvent)&event_title=\(event.title)&lat=\(event.latitude)&long=\(event.longitude)"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: postMsg) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if statusCode != 200 {
                        // error occured
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
                        }
                        completionHandler(false)
                        return
                    }
                    
                    guard data != nil else {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                        }
                        completionHandler(false)
                        return
                    }
                    
                    guard let server_response = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
                        [String : String] else {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                            }
                            completionHandler(false)
                            return
                    }
                    
                    if server_response["status"] == "error" {
                        if view != nil {
                            let err = server_response["error"]!
                            let errorMsg = "Error: \(String(describing: err))"
                            UIUtils.showAlert(view: view!, title: "Failed to Modify Event", message: errorMsg)
                        }
                        completionHandler(false)
                        return
                    }
                    
                    completionHandler(true)
                }
            }
        }
    }
}
