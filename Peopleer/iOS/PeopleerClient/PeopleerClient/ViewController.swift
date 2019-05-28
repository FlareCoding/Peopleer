//
//  ViewController.swift
//  PeopleerClient
//
//  Created by Albert Slepak on 4/21/19.
//  Copyright © 2019 Albert Slepak. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var openMapBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func OpenMap(_ sender: UIButton) {
        performSegue(withIdentifier: "openMapSegue", sender: self)
    }
    
    @IBAction func LogoutButton_OnClick(_ sender: UIBarButtonItem) {
        
        let manager = CoreDataManager.shared
        let objects = manager.retrieveObjects(entity: "RememberMe")
        if objects != nil && objects!.count > 0 {
            objects![0].setValue(false, forKey: "enabled")
            _ = manager.saveContext()
        }
        
        performSegue(withIdentifier: "logoutSegue", sender: self)
    }
}

