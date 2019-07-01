//
//  EventDataManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/25/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation
import UIKit

enum EventSearchFilter {
    case owner
    case title
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
        static let JoinEvent            = "join_event"
        static let IsUserInEvent        = "is_user_in_event"
        static let GetEventsBasedOnOwner = "get_events_based_on_owner"
        static let GetEventsBasedOnTitle = "get_events_based_on_title"
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
    
    func RetrieveAllEvents(view: UIViewController? = nil, completionHandler: @escaping (_ events: [Event]) -> Void) {
        self.events = [] // removing all existing events
        
        let requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.GetAllEvents)
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [[String : Any]]) in
                        
                        for event in serverResponse {
                            self.events.append(self.ParseEventData(event: event))
                        }
                        
                    }) == true) else {
                        completionHandler(self.events)
                        return
                    }
                }
                
                completionHandler(self.events)
            }
        }
    }
    
    func CreateNewEvent(view: UIViewController? = nil, event: Event, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.InsertEvent)
        requestBuilder.addAttrib(name: "lat",                   value: event.latitude)
        requestBuilder.addAttrib(name: "long",                  value: event.longitude)
        requestBuilder.addAttrib(name: "event_title",           value: event.title)
        requestBuilder.addAttrib(name: "username",              value: LoginManager.username)
        requestBuilder.addAttrib(name: "address",               value: event.address)
        requestBuilder.addAttrib(name: "description",           value: event.description)
        requestBuilder.addAttrib(name: "start_time",            value: DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.startTime))
        requestBuilder.addAttrib(name: "end_time",              value: DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.endTime))
        requestBuilder.addAttrib(name: "max_participants",      value: event.maxParticipants)
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [String : String]) in
                        
                        if serverResponse["status"] == "error" {
                            if view != nil {
                                let err = serverResponse["error"]!
                                var errorMsg = "\(String(describing: err))"
                                if err.contains("Duplicate entry") {
                                    errorMsg = "Event with this exact location already exists"
                                }
                                
                                UIUtils.showAlert(view: view!, title: "Failed to Create Event", message: errorMsg)
                            }
                            completionHandler(false)
                            return
                        }
                        
                    }) == true) else {
                        completionHandler(false)
                        return
                    }
                    
                    completionHandler(true)
                    return
                }
                
                completionHandler(false)
            }
        }
    }
    
    func GetSpecificEvent(event: Event, view: UIViewController? = nil, completionHandler: @escaping (_ event: Event?) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.GetSpecificEvent)
        requestBuilder.addAttrib(name: "lat",   value: event.latitude)
        requestBuilder.addAttrib(name: "long",  value: event.longitude)
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    var result_evt: Event? = nil
                    
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [[String : String]]) in
                        
                        if serverResponse.count < 1 {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "Error", message: "Could not load event data")
                            }
                            completionHandler(result_evt)
                            return
                        }
                        
                        let event_data = serverResponse[0]
                        result_evt = self.ParseEventData(event: event_data)
                        
                    }) == true) else {
                        completionHandler(result_evt)
                        return
                    }
                    
                    completionHandler(result_evt)
                    return
                }
                
                completionHandler(nil)
            }
        }
    }
    
    func DeleteEvent(event: Event, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.DeleteEvent)
        requestBuilder.addAttrib(name: "lat",   value: event.latitude)
        requestBuilder.addAttrib(name: "long",  value: event.longitude)
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [String : String]) in
                        
                        if serverResponse["status"] == "error" {
                            if view != nil {
                                let err = serverResponse["error"]!
                                let errorMsg = "\(String(describing: err))"
                                UIUtils.showAlert(view: view!, title: "Failed to Create Event", message: errorMsg)
                            }
                            completionHandler(false)
                            return
                        }
                        
                    }) == true) else {
                        completionHandler(false)
                        return
                    }
                    
                    completionHandler(true)
                    return
                }
                
                completionHandler(false)
            }
        }
    }
    
    func ModifyEvent(event: Event, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.ModifyEvent)
        requestBuilder.addAttrib(name: "lat",                   value: event.latitude)
        requestBuilder.addAttrib(name: "long",                  value: event.longitude)
        requestBuilder.addAttrib(name: "event_title",           value: event.title)
        requestBuilder.addAttrib(name: "username",              value: LoginManager.username)
        requestBuilder.addAttrib(name: "address",               value: event.address)
        requestBuilder.addAttrib(name: "description",           value: event.description)
        requestBuilder.addAttrib(name: "start_time",            value: DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.startTime))
        requestBuilder.addAttrib(name: "end_time",              value: DateTimeUtils.getEventDateAndTimeDBCompatFormat(date: event.endTime))
        requestBuilder.addAttrib(name: "max_participants",      value: event.maxParticipants)
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [String : String]) in
                        
                        if serverResponse["status"] == "error" {
                            if view != nil {
                                let err = serverResponse["error"]!
                                let errorMsg = "\(String(describing: err))"
                                UIUtils.showAlert(view: view!, title: "Failed to Modify Event", message: errorMsg)
                            }
                            completionHandler(false)
                            return
                        }
                        
                    }) == true) else {
                        completionHandler(false)
                        return
                    }
                    
                    completionHandler(true)
                    return
                }
                
                completionHandler(false)
            }
        }
    }
    
    func RetrieveEventsBasedOnFilter(view: UIViewController? = nil, eventSearchFilter: EventSearchFilter, filter: String, completionHandler: @escaping (_ events: [Event]) -> Void) {
        
        var requestBuilder = ServerRequestBuilder(servreq: "")
        
        if eventSearchFilter == .owner {
            requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.GetEventsBasedOnOwner)
            requestBuilder.addAttrib(name: "username",    value: filter)
        }
        
        if eventSearchFilter == .title {
            requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.GetEventsBasedOnTitle)
            requestBuilder.addAttrib(name: "event_title", value: filter)
        }
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                var retrievedEvents: [Event] = []
                
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [[String : Any]]) in
                        
                        for event in serverResponse {
                            retrievedEvents.append(self.ParseEventData(event: event))
                        }
                        
                    }) == true) else {
                        completionHandler(retrievedEvents)
                        return
                    }
                }
                
                completionHandler(retrievedEvents)
            }
        }
    }
    
    func SignUserUpForEvent(view: UIViewController? = nil, userToSignUp: String, event: Event, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.JoinEvent)
        requestBuilder.addAttrib(name: "lat",   value: event.latitude)
        requestBuilder.addAttrib(name: "long",  value: event.longitude)
        requestBuilder.addAttrib(name: "user",  value: userToSignUp)
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [String : String]) in
                        
                        if serverResponse["status"] == "error" {
                            if view != nil {
                                let err = serverResponse["error"]!
                                var errorMsg = "\(String(describing: err))"
                                if err.contains("Duplicate entry") {
                                    errorMsg = "You are already participating in this event"
                                }
                                UIUtils.showAlert(view: view!, title: "Error Joining Event", message: errorMsg)
                            }
                            completionHandler(false)
                            return
                        }
                        
                        completionHandler(true)
                        return
                        
                    }) == true) else {
                        completionHandler(false)
                        return
                    }
                }
                
                completionHandler(false)
            }
        }
    }
    
    func IsUserSignedUpForEvent(view: UIViewController? = nil, user: String, event: Event, completionHandler: @escaping (_ userSignedUp: Bool) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: EventServiceRequests.IsUserInEvent)
        requestBuilder.addAttrib(name: "lat",   value: event.latitude)
        requestBuilder.addAttrib(name: "long",  value: event.longitude)
        requestBuilder.addAttrib(name: "user",  value: user)
        
        NetworkManager.shared.postRequest(url: EVENTS_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [String : String]) in
                        
                        let isUserSignedUp = Bool(serverResponse["result"] ?? "false") ?? false
                        completionHandler(isUserSignedUp)
                        return
                        
                    }) == true) else {
                        completionHandler(false)
                        return
                    }
                }
                
                completionHandler(false)
            }
        }
    }
}
