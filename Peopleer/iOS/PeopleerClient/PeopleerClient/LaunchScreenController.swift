//
//  LaunchScreenController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/22/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class LaunchScreenController : UIViewController {
    
    @IBOutlet weak var logo: UILabel!
    
    let fadeDuration = 1.1
    let windowViewTransitionDuration = 0.6
    
    override func viewDidLoad() {
        self.logo.alpha = 0
        
        // Fade in the logo
        UIView.animate(withDuration: self.fadeDuration, delay: 0.5, animations: { () -> Void in
            self.logo.alpha = 1
        }) { (Bool) -> Void in
            // Fade out the logo
            UIView.animate(withDuration: self.fadeDuration, delay: 0.2, animations: { () -> Void in
                self.logo.alpha = 0
            }) { (success) in
                // Transition to the main menu screen
                let sb = UIStoryboard(name: "Main", bundle: nil)
                
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
                                
                                let vc = sb.instantiateViewController(withIdentifier: "MainViewController") as! ViewController
                                UIView.transition(with: UIApplication.shared.keyWindow!, duration: self.windowViewTransitionDuration, options: .transitionCrossDissolve, animations: {
                                    UIApplication.shared.keyWindow?.rootViewController = vc
                                })
                            }
                            else if error != nil {
                                UIUtils.showAlert(view: self, title: "Connection Failed", message: "Failed to connect to the server") {
                                    let vc = sb.instantiateViewController(withIdentifier: "LoginScreenViewController") as! LoginScreenViewController
                                    UIView.transition(with: UIApplication.shared.keyWindow!, duration: self.windowViewTransitionDuration, options: .transitionCrossDissolve, animations: {
                                        UIApplication.shared.keyWindow?.rootViewController = vc
                                    })
                                }
                            }
                            else {
                                // For any other reason
                                UIUtils.showAlert(view: self, title: "Account Error", message: "Failed to retrieve user account information") {
                                    let vc = sb.instantiateViewController(withIdentifier: "LoginScreenViewController") as! LoginScreenViewController
                                    UIView.transition(with: UIApplication.shared.keyWindow!, duration: self.windowViewTransitionDuration, options: .transitionCrossDissolve, animations: {
                                        UIApplication.shared.keyWindow?.rootViewController = vc
                                    })
                                }
                            }
                        }
                    }
                    else {
                        let vc = sb.instantiateViewController(withIdentifier: "LoginScreenViewController") as! LoginScreenViewController
                        
                        UIView.transition(with: UIApplication.shared.keyWindow!, duration: self.windowViewTransitionDuration, options: .transitionCrossDissolve, animations: {
                            UIApplication.shared.keyWindow?.rootViewController = vc
                        })
                        
                        vc.rememberMeSwitch.isOn = false
                        
                        if objects?.count == 1 {
                            vc.usernameTextfield.text = objects![0].value(forKey: "username") as? String
                        }
                    }
                }
                else {
                    let vc: LoginScreenViewController = sb.instantiateViewController(withIdentifier: "LoginScreenViewController") as! LoginScreenViewController
                    UIView.transition(with: UIApplication.shared.keyWindow!, duration: self.windowViewTransitionDuration, options: .transitionCrossDissolve, animations: {
                        UIApplication.shared.keyWindow?.rootViewController = vc
                    })
                    
                    vc.rememberMeSwitch.isOn = false
                }
            }
        }
    }
}
