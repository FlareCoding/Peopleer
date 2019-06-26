//
//  LoginManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/10/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

struct User {
    var username    = "Error"
    var country     = "Error"
    var city        = "Error"
    var hoursVolunteered = 0
    var impact = 0
}

class LoginManager {
    
    static var username = ""
    static var password = ""
    
    static private func validateEmail(email: String) -> Bool {
        
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: email)
        
    }
    
    static func LoginUser(username: String, password: String, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool, _ error: Error?) -> Void) {
        var postMsg = "servreq=login&username=\(username)&password=\(password.sha256())"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: LOGIN_URL, postMsg: postMsg) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if statusCode != 200 {
                        // error occured
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
                        }
                        completionHandler(false, error)
                        return
                    }
                    
                    guard data != nil else {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                        }
                        completionHandler(false, error)
                        return
                    }
                    
                    guard let server_response = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
                        [String : String] else {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "JSON Error", message: "Received data was corrupt")
                            }
                            completionHandler(false, error)
                            return
                    }
                    
                    if server_response["status"] == "error" {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Incorrect Login Info", message: server_response["error"] ?? "Unknown Error")
                        }
                        completionHandler(false, error)
                        return
                    }
                    
                    completionHandler(true, error)
                }
                
                completionHandler(false, error)
            }
        }
    }
    
    static func SignupUser(username: String, email: String, password: String, view: UIViewController? = nil, completionHandler: @escaping
        (_ succeeded: Bool, _ error: Error?, _ errorString: String?) -> Void) {
        
        var postMsg = "servreq=signup&username=\(username)&email=\(email)&password=\(password.sha256())"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: LOGIN_URL, postMsg: postMsg) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if statusCode != 200 {
                        // error occured
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
                        }
                        completionHandler(false, error, nil)
                        return
                    }
                    
                    guard data != nil else {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                        }
                        completionHandler(false, error, nil)
                        return
                    }
                    
                    guard let server_response = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
                        [String : String] else {
                            if view != nil {
                                UIUtils.showAlert(view: view!, title: "JSON Error", message: "Received data was corrupt")
                            }
                            completionHandler(false, error, nil)
                            return
                    }
                    
                    if server_response["status"] == "error" {
                        let err = server_response["error"]!
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
                    
                    completionHandler(true, error, nil)
                }
            }
        }
    }
}
