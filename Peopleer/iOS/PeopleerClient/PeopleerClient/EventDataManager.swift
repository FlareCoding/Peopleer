//
//  EventDataManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/25/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation
import UIKit

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
                        owner: event["owner"] as! String,
                        latitude: (event["latitude"] as! NSString).doubleValue,
                        longitude: (event["longitude"] as! NSString).doubleValue,
                        description: event["description"] as! String,
                        address: event["address"] as! String,
                        maxParticipants: Int((event["max_participants"] as! NSString).intValue),
                        currentParticipants: Int((event["current_participants"] as! NSString).intValue),
                        startTime: (event["start_time"] as! String).toCorrectDate(),
                        endTime: (event["end_time"] as! String).toCorrectDate())
        return evt
    }
    
    func CreateNewEvent(view: UIViewController? = nil, event: Event, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.InsertEvent)&event_title=\(event.title)&lat=\(event.latitude)&long=\(event.longitude)&username=\(LoginManager.username)&address=\(event.address)&description=\(event.description)&start_time=\(DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.startTime))&end_time=\(DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.endTime))&max_participants=\(String(event.maxParticipants))"
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
                                errorMsg = "Event with this exact location already exists"
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
    
    func GetSpecificEvent(event: Event, view: UIViewController? = nil, completionHandler: @escaping (_ event: Event?) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.GetSpecificEvent)&lat=\(event.latitude)&long=\(event.longitude)"
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
    
    func DeleteEvent(event: Event, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.DeleteEvent)&lat=\(event.latitude)&long=\(event.longitude)"
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
    
    func ModifyEvent(event: Event, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        var postMsg = "servreq=\(EventServiceRequests.ModifyEvent)&lat=\(event.latitude)&long=\(event.longitude)&event_title=\(event.title)&username=\(LoginManager.username)&address=\(event.address)&description=\(event.description)&start_time=\(DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.startTime))&end_time=\(DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.endTime))&max_participants=\(String(event.maxParticipants))"
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
