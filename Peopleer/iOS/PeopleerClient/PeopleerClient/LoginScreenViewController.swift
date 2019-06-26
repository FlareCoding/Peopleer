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
    @IBOutlet weak var rememberMeSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextfield.delegate = self
        self.passwordTextfield.delegate = self
        
        //
        // Pull value of "RememberMe" field from CoreData and if the value is true, then send the login request to the server.
        // If the value is false, then set username textfield text to last used username retrieved from CoreData.
        //
        let manager = CoreDataManager.shared
        let objects = manager.retrieveObjects(entity: "RememberMe")
        if objects != nil {
            let rememberMeEnabled = manager.getObject(managedObjectPool: objects!, keyName: "enabled", value: true)
            
            if objects?.count == 1 && rememberMeEnabled != nil {
                let rememberMeObject = objects![0]
                let usernameString = rememberMeObject.value(forKey: "username") as! String
                let passwordString = rememberMeObject.value(forKey: "password") as! String
                
                LoginManager.LoginUser(username: usernameString, password: passwordString, view: self) { succeeded, error  in
                    if succeeded {
                        LoginManager.username = usernameString
                        LoginManager.password = passwordString
                        self.performSegue(withIdentifier: "OpenMainMenuSegue", sender: nil)
                    }
                    else if error != nil {
                        UIUtils.showAlert(view: self, title: "Connection Failed", message: "Failed to connect to the server")
                    }
                }
            }
            else {
                if objects?.count == 1 {
                    usernameTextfield.text = objects![0].value(forKey: "username") as? String
                }
                
                rememberMeSwitch.isOn = false
            }
        }
        else {
            rememberMeSwitch.isOn = false
        }
    }
    
    @IBAction func Login(_ sender: UIButton) {
        sender.isEnabled = false
        let username = usernameTextfield.text!
        let password = passwordTextfield.text!
        
        LoginManager.LoginUser(username: username, password: password, view: self) { succeeded, error in
            sender.isEnabled = true
            
            if succeeded {
                LoginManager.username = username
                LoginManager.password = password
                
                let manager = CoreDataManager.shared
                let objects = manager.retrieveObjects(entity: "RememberMe")
                if objects != nil {
                    if objects?.count == 0 {
                        // Insert new object if it doesn't exist already
                        _ = manager.insertData(entity: "RememberMe", attribs: [
                            "enabled": self.rememberMeSwitch.isOn,
                            "username": username,
                            "password": password
                            ])
                    }
                    else {
                        // Update username and password of existing object
                        objects![0].setValue(username, forKey: "username")
                        objects![0].setValue(password, forKey: "password")
                        objects![0].setValue(self.rememberMeSwitch.isOn, forKey: "enabled")
                        _ = manager.saveContext()
                    }
                }
                else {
                    // Insert new object because it doesn't exist yet ("objects" is nil)
                    _ = manager.insertData(entity: "RememberMe", attribs: [
                        "enabled": self.rememberMeSwitch.isOn,
                        "username": username,
                        "password": password
                        ])
                }
                
                self.performSegue(withIdentifier: "OpenMainMenuSegue", sender: nil)
            }
            else if error != nil {
                // Failed to connect to the server
                UIUtils.showAlert(view: self, title: "Connection Failed", message: "Failed to connect to the server")
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide keyboard when "return" key is pressed
        textField.resignFirstResponder()
        return true
    }
}
