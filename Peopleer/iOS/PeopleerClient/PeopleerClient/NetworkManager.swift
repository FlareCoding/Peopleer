//
//  NetworkManager.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/29/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import Foundation

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
}
