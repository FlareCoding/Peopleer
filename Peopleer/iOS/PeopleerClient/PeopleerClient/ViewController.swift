//
//  ViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/21/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var navigationBarTitleItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adds username to the navigation bar title
        navigationBarTitleItem.title = LoginManager.username
    }
    
    @IBAction func MyProfile_OnClick(_ sender: UIButton) {
        // Opens view controller displaying user profile
        performSegue(withIdentifier: "openMyProfileSegue", sender: nil)
    }
    
    @IBAction func OpenMap_OnClick(_ sender: UIButton) {
        // Opens view controller displaying the main map
        performSegue(withIdentifier: "openMapSegue", sender: self)
    }
    
    @IBAction func MyEvents_OnClick(_ sender: UIButton) {
        // Opens view controller displaying events created by the user
        performSegue(withIdentifier: "viewMyEventsSegue", sender: self)
    }
    
    @IBAction func LogoutButton_OnClick(_ sender: UIBarButtonItem) {
        // Performs logout operation
        let manager = CoreDataManager.shared
        let objects = manager.retrieveObjects(entity: "RememberMe")
        if objects != nil && objects!.count > 0 {
            objects![0].setValue(false, forKey: "enabled") // disables the "remember me" option
            _ = manager.saveContext()
        }
        
        // Performs segue back to the login page
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
}

