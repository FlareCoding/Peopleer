//
//  NetworkManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/29/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation
import UIKit

class ServerRequestBuilder {
    private var postMessageString = ""
    
    init(servreq: String) {
        postMessageString = "servreq=\(servreq)"
    }
    
    func addAttrib(name: String, value: Any) {
        postMessageString.append("&\(name)=\(value)")
    }
    
    func getPostRequest() -> String {
        return postMessageString.replacingOccurrences(of: " ", with: "%20")
    }
}

class NetworkManager {
    
    static let shared = NetworkManager()
    
    private let session: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 2
        configuration.timeoutIntervalForResource = 2
        configuration.requestCachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalCacheData
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }()
    
    func getRequest(url: String, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let _urlo = URL(string: url)!
        let dataTask = session.dataTask(with: _urlo) { data, response, error in
            completionHandler(data, response, error)
        }
        dataTask.resume()
    }
    
    func postRequest(url: String, postMsg: String, completionHandler: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
        let _urlo = URL(string: url)!
        var request = URLRequest(url: _urlo)
        request.httpMethod = "POST"
        request.httpBody = postMsg.data(using: String.Encoding.utf8)
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            completionHandler(data, response, error)
        }
        dataTask.resume()
    }
    
    func CheckReceivedServerData<T>(httpResponse: HTTPURLResponse, data: Data?, view: UIViewController?,
                                            completion: (_ serverResponse: T) -> Void) -> Bool {
        let statusCode = httpResponse.statusCode
        if statusCode != 200 {
            // error occured
            if view != nil {
                UIUtils.showAlert(view: view!, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
            }
            return false
        }
        
        guard data != nil else {
            if view != nil {
                UIUtils.showAlert(view: view!, title: "Response Error", message: "No data was received")
            }
            return false
        }
        
        guard let serverResponse = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
            T else {
                if view != nil {
                    UIUtils.showAlert(view: view!, title: "Response Error", message: "Server response was corrupt")
                }
                return false
        }
        
        completion(serverResponse)
        return true
    }
}
