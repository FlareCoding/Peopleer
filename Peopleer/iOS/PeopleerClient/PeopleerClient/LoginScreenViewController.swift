//
//  LoginScreenViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 5/8/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class LoginScreenViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    
    private let LOGIN_URL = "http://172.20.10.3:8000/peopleer_login_service.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextfield.delegate = self
        self.passwordTextfield.delegate = self
    }
    
    @IBAction func Login(_ sender: UIButton) {
        sender.isEnabled = false
        let username = usernameTextfield.text!
        let password = passwordTextfield.text!.sha256()
        
        var postMsg = "servreq=0&username=\(username)&password=\(password)"
        postMsg = postMsg.replacingOccurrences(of: " ", with: "%20")
        
        NetworkManager.shared.postRequest(url: LOGIN_URL, postMsg: postMsg) { data, response, error in
            DispatchQueue.main.async {
                if let HTTPResponse = response as? HTTPURLResponse {
                    let statusCode = HTTPResponse.statusCode
                    if statusCode != 200 {
                        // error occured
                        UIUtils.showAlert(view: self, title: "Server Error", message: "Error occured while connecting to the server\nError Code: \(statusCode)")
                        sender.isEnabled = true
                        return
                    }
                    
                    guard data != nil else {
                        UIUtils.showAlert(view: self, title: "Response Error", message: "Server response was corrupt")
                        sender.isEnabled = true
                        return
                    }
                    
                    guard let server_response = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as?
                        [String : String] else {
                            UIUtils.showAlert(view: self, title: "JSON Error", message: "Received data was corrupt")
                            sender.isEnabled = true
                            return
                    }
                    
                    if server_response["status"] == "error" {
                        UIUtils.showAlert(view: self, title: "Incorrect Login Info", message: server_response["error"] ?? "Unknown Error")
                        sender.isEnabled = true
                        return
                    }
                    
                    sender.isEnabled = true
                    self.performSegue(withIdentifier: "OpenMainMenuSegue", sender: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension String {
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
}
