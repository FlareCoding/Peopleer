//
//  LoginManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/10/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class LoginManager {
    
    static var username = ""
    static var password = ""
    
    static var userObject = User()
    
    static private func validateEmail(email: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
        
    }
    
    static func LoginUser(username: String, password: String, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool, _ error: Error?) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: "login")
        requestBuilder.addAttrib(name: "username", value: username)
        requestBuilder.addAttrib(name: "password", value: password.sha256())
        
        NetworkManager.shared.postRequest(url: LOGIN_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [String : String]) in
                        
                        if serverResponse["status"] == "error" {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "Incorrect Login Info", message: serverResponse["error"] ?? "Unknown Error")
                            }
                            completionHandler(false, error)
                            return
                        }
                        
                        completionHandler(true, error)
                        
                        // update global user struct object
                        UserDataManager.shared.GetUserInformation(view: view, username: username) { user in
                            if user != nil {
                                userObject = user!
                            }
                        }
                        
                        return
                        
                    }) == true) else {
                        completionHandler(false, error)
                        return
                    }
                }
                
                completionHandler(false, error)
            }
        }
    }
    
    static func SignupUser(view: UIViewController? = nil, user: User, password: String, completionHandler: @escaping
        (_ succeeded: Bool, _ error: Error?, _ errorString: String?) -> Void) {
        
        let requestBuilder = ServerRequestBuilder(servreq: "signup")
        requestBuilder.addAttrib(name: "username", value: user.username)
        requestBuilder.addAttrib(name: "displayed_name", value: user.displayedName)
        requestBuilder.addAttrib(name: "email",    value: user.email)
        requestBuilder.addAttrib(name: "country",  value: user.country)
        requestBuilder.addAttrib(name: "city",     value: user.city)
        requestBuilder.addAttrib(name: "hours_volunteered", value: user.hoursVolunteered)
        requestBuilder.addAttrib(name: "impact",   value: user.impact)
        requestBuilder.addAttrib(name: "password", value: password.sha256())
        
        NetworkManager.shared.postRequest(url: LOGIN_SERVICE_URL, postMsg: requestBuilder.getPostRequest()) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    guard (NetworkManager.shared.CheckReceivedServerData(httpResponse: HTTPResponse, data: data, view: view, completion: {
                        (serverResponse: [String : String]) in
                        
                        if serverResponse["status"] == "error" {
                            let err = serverResponse["error"]!
                            var errorMsg = "Error: \(String(describing: err))"
                            if err.contains("Duplicate entry") {
                                errorMsg = "Username taken"
                            }
                            
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "Registration Failed", message: errorMsg)
                            }
                            
                            completionHandler(false, error, errorMsg)
                            return
                        }
                        
                    }) == true) else {
                        completionHandler(false, error, nil)
                        return
                    }
                    
                    completionHandler(true, error, nil)
                    return
                }
                
                completionHandler(false, error, nil)
            }
        }
    }
}
