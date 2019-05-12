//
//  LoginManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/10/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class LoginManager {
    
    private static let LOGIN_URL = "http://158.222.244.80:8000/peopleer_login_service.php"
    
    static var username = ""
    static var password = ""
    
    static func LoginUser(username: String, password: String, view: UIViewController? = nil, completionHandler: @escaping (_ succeeded: Bool) -> Void) {
        var postMsg = "servreq=0&username=\(username)&password=\(password.sha256())"
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
                                UIUtils.showAlert(view: view!, title: "JSON Error", message: "Received data was corrupt")
                            }
                            completionHandler(false)
                            return
                    }
                    
                    if server_response["status"] == "error" {
                        if view != nil {
                            UIUtils.showAlert(view: view!, title: "Incorrect Login Info", message: server_response["error"] ?? "Unknown Error")
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
