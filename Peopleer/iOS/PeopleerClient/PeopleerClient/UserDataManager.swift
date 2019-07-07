//
//  UserDataManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 7/3/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation
import UIKit

class UserDataManager {
    
    static let shared = UserDataManager()
    
    private struct UserServiceRequests {
        static let GetUserInfo          = "get_user_info"
        static let GetEventParticipants = "get_event_participants"
    }
    
    private func ParseUserData(data: [String : Any]) -> User {
        let user = User(username:           data["username"] as! String,
                        displayedName:      data["displayed_name"] as! String,
                        email:              data["email"] as! String,
                        country:            data["country"] as! String,
                        city:               data["city"] as! String,
                        hoursVolunteered:   Int(data["hours_volunteered"] as! String) ?? 0,
                        impact:             Int(data["impact"] as! String) ?? 0)
        return user
    }
    
    func GetUserInformation(view: UIViewController? = nil, username: String, completionHandler: @escaping (_ user: User?) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: UserServiceRequests.GetUserInfo)
        requestBuilder.addAttrib(name: "username", value: username)
        
        NetworkManager.shared.postRequest(url: USER_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    var user: User? = nil
                    
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [[String : String]]) in
                        
                        if serverResponse.count < 1 {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "Error", message: "Could not load user data")
                            }
                            completionHandler(nil)
                            return
                        }
                        
                        let user_data = serverResponse[0]
                        user = self.ParseUserData(data: user_data)
                        
                    }) == true) else {
                        completionHandler(nil)
                        return
                    }
                    
                    completionHandler(user)
                    return
                }
                
                completionHandler(nil)
            }
        }
    }
    
    func GetEventParticipants(view: UIViewController? = nil, event: Event, completionHandler: @escaping (_ users: [User]) -> Void) {
        let requestBuilder = ServerRequestBuilder(servreq: UserServiceRequests.GetEventParticipants)
        requestBuilder.addAttrib(name: "lat",  value: event.latitude)
        requestBuilder.addAttrib(name: "long", value: event.longitude)
        
        NetworkManager.shared.postRequest(url: USER_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                var users: [User] = []
                
                if let HTTPResponse = response as? HTTPURLResponse {
                    
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [[String : String]]) in
                        
                        for user in serverResponse {
                            users.append(self.ParseUserData(data: user))
                        }
                        
                    }) == true) else {
                        completionHandler(users)
                        return
                    }
                    
                    completionHandler(users)
                    return
                }
                
                completionHandler(users)
            }
        }
    }
}
